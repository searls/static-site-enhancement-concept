module Commands
  class UpdatePublishDateCache
    def initialize
      @updated_files = []
      @publish_dates = {}
    end

    def should_run?(config)
      last_updated_at = config.dig("publish_dates", "last_updated_at")

      since_flag = last_updated_at.nil? ? "" : " --since=#{last_updated_at.iso8601.inspect} "
      @updated_files = %x(
        git log #{since_flag} --name-only --pretty=format: -- \
          content/casts \
          content/clips \
          content/links \
          content/mails \
          content/posts \
          content/shots \
          content/slops \
          content/takes \
          content/tubes \
        | sort -u).strip.split(/\s+/)
        .map { |f| f.gsub(/\A"(.*)"\z/, '\1') }
        .reject { |f| File.basename(f).start_with?("_") }

      @updated_files.any?
    end

    def run(config)
      @publish_dates = @updated_files.map { |f|
        begin
          content = Content.parse(File.read(f))
          if (publish_date_content = content.frontmatter["date"])
            [f, massage_publish_date(publish_date_content)]
          end
        rescue Errno::ENOENT
        end
      }.compact.to_h
    end

    def updated_config(config)
      if @publish_dates.any?
        {
          "publish_dates" => {
            "last_updated_at" => Time.now.utc,
            "cache" => (config.dig("publish_dates", "cache") || {}).merge(@publish_dates)
          }
        }
      end
    end

    private

    def massage_publish_date(publish_date_content)
      case publish_date_content
      when Time then publish_date_content
      when Date then publish_date_content.to_time
      when String
        begin
          Time.parse(publish_date_content)
        rescue
          raise "Bad date found in frontmatter for #{f}: #{publish_date_content}"
        end
      end
    end
  end
end
