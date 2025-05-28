module Scan
  CONTENT_DIR = File.expand_path("../../content", __dir__)

  def self.content_files(*types, after_date:)
    Dir["#{CONTENT_DIR}/{#{types.map(&:to_s).join(",")}}/**/*.md"]
      .reject { |f| File.basename(f).start_with?("_") }
      .then { |files|
        if after_date.nil?
          files
        else
          files.select { |f| File.basename(f, ".md") > after_date }
        end
      }
  end
end
