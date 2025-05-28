module Commands
  class AdvancePublicationDate
    def should_run?(config)
      @last_published_at = config.dig("publish_dates", "last_published_at")

      @last_published_at.nil? || config.dig("publish_dates", "cache").any? { |k, v|
        v > @last_published_at
      }
    end

    def run(config)
      # Nothing actually to be done here, we just know the config needs to be churned to trigger a netlify build
    end

    def updated_config(config)
      {
        "publish_dates" => {
          "last_published_at" => Time.now.utc
        }
      }
    end
  end
end
