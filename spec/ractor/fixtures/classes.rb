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

class MultiplierServer
  include Ractor::Supervisor::Server
  attr_accessor :factor
  sync :factor
  async :factor=

  def initialize(factor)
    @factor = factor
  end

  sync def transform(number)
    @factor * number
  end
end

class AfineServer < MultiplierServer
  attr_accessor :offset
  sync :offset
  async :offset=

  def initialize(factor, offset:)
    @offset = offset
    super(factor)
  end

  sync def transform(number)
    super + @offset
  end

  async def wait_async(delay)
    sleep(delay)
    42
  end

  sync def wait_sync(delay)
    sleep(delay)
    42
  end
end
