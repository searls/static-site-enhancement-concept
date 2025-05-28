class QuotedString < String
  def encode_with(coder)
    coder.scalar = self
    coder.style = Psych::Nodes::Scalar::DOUBLE_QUOTED
    coder.tag = nil
  end
end
