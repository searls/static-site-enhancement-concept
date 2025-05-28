require "yaml"
require "fileutils"
require "deep_merge/rails_compat"

module EnhancementConfig
  PATH = File.expand_path("../../config/enhancements.yml", __dir__)

  def self.load
    YAML.load_file(PATH, permitted_classes: [Time, Date])
  rescue Errno::ENOENT
    {}
  end

  def self.update!(config, config_update)
    FileUtils.mkdir_p(File.dirname(PATH))
    config.deeper_merge!(config_update, {overwrite_arrays: true, merge_nil_values: true}).tap do |config|
      File.write(PATH, config.to_yaml)
    end
  end
end
