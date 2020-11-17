# frozen_string_literal: true

class Multiplier
  def initialize(factor)
    @factor = factor
    @last = 0
  end

  def run
    loop do
      Ractor.receive
    end
  end
end
