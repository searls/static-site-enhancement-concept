module De
  def self.bug(msg)
    return unless ENV["DE_BUG"]
    @@indent_level ||= 0
    puts "#{"  " * @@indent_level}#{msg}"
  end

  def self.in
    @@indent_level ||= 0
    @@indent_level += 1
    bug "---"
  end

  def self.out
    @@indent_level ||= 0
    @@indent_level -= 1
  end
end
