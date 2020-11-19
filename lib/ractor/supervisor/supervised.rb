# frozen_string_literal: true

module Ractor
  class Supervisor
    Supervised = ::DelegateClass(::Ractor)

    class Supervised
      attr_reader :ractor

      alias_method :__getobj__, :ractor
    end

    module Internals
      refine Supervised do
        attr_writer :ractor
      end
    end
  end
end
