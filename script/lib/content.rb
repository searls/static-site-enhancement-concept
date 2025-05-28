require "yaml"

module Content
  Value = Struct.new(:frontmatter, :body)

  def self.parse(content)
    if content =~ /\A---\s*\n(.*?)\n---\s*\n(.*)/m
      Value.new(YAML.safe_load($1, permitted_classes: [Time, Date]) || {}, $2)
    else
      Value.new({}, content)
    end
  end

  def self.dump(frontmatter:, body:)
    "#{frontmatter.to_yaml}---\n\n#{body}"
  end
end
