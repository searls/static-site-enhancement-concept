require "open-uri"
require "nokogiri"

module Commands
  class AddCardsToTakes
    def initialize
      @last_processed_file = nil
      @take_files = nil
    end

    def should_run?(config)
      @take_files = Scan.content_files(:takes, after_date: config.dig("takes", "card_metadata_fetched_through"))
      @take_files.any?
    end

    def run(config)
      @take_files.sort.each do |file|
        De.in
        @last_processed_file = file
        De.bug "Processing file: #{file}"
        content = Content.parse(File.read(file))
        urls = urls_in_text(content.body)
        De.bug "URLs found: #{urls.inspect}"
        if !urls.empty?
          card_data = urls.map do |url|
            De.in
            De.bug "Fetching URL: #{url}"
            resp = fetch_url(url)
            if resp && resp.content_type&.include?("html")
              doc = Nokogiri::HTML(resp.read)
              title = doc.at("title")&.text&.strip
              og_image = doc.at('meta[property="og:image"]')&.[]("content")
              De.bug "Parsed title: #{title}"
              De.bug "Parsed image_url: #{og_image}"
              if og_image&.match?(/\A(https?:\/\/|\/\/)/)
                [QuotedString.new(url.to_s), {
                  "title" => QuotedString.new(title.to_s),
                  "image_url" => QuotedString.new(og_image.to_s)
                }]
              end
            end.tap { De.out }
          end.compact.to_h
          if !card_data.empty?
            De.bug "Writing cards: #{card_data.inspect}"
            File.write(file, Content.dump(
              frontmatter: content.frontmatter.merge("cards" => card_data),
              body: content.body
            ))
          else
            De.bug "No card data to write."
          end
        else
          De.bug "No URLs found."
        end
        De.out
      end
    end

    def updated_config(config)
      if @last_processed_file
        {
          "takes" => {
            "card_metadata_fetched_through" => File.basename(@last_processed_file, ".md")
          }
        }
      end
    end

    private

    def urls_in_text(text)
      URI.extract(text, %w[http https])
    end

    def fetch_url(url)
      URI.parse(url).open(redirect: true)
    rescue => e
      De.bug "      Failed to open '#{url}': #{e.class}: #{e.message}"
      nil
    end
  end
end
