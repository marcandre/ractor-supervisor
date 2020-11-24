# frozen_string_literal: true

class Ractor
  class Supervisor
    Specs = Struct.new(:children, :strategy)

    class Specs
      STRATEGIES = %i[one_for_one one_for_all rest_for_one].freeze

      attr_reader :strategy

      def initialize(children = [], strategy: :one_for_one)
        yield children if block_given?

        super(children, strategy)

        Ractor.make_shareable(self)
      end
    end
  end
end
