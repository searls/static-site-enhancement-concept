# DANGER: Monkey-patch Time to ensure it serializes as a plain scalar in YAML (which hugo wants)
class Time
  FORMAT = "%Y-%m-%dT%H:%M:%S.%3NZ".freeze

  # Psych hook ─ keeps the scalar plain & un-quoted
  def encode_with(coder)
    coder.scalar = strftime(FORMAT)
    coder.style = Psych::Nodes::Scalar::PLAIN
    coder.tag = nil
  end
end
