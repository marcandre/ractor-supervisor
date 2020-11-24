# frozen_string_literal: true

class Ractor
  class Supervisor
    class Supervised < DelegateClass(::Ractor)
      def initialize(supervisor:, child_index:, ractor:)
        @ractor = ractor
        @supervisor = supervisor
        @child_index = child_index
        super()
      end
      attr_reader :ractor

      alias_method :__getobj__, :ractor

      Ractor.instance_methods(false).each do |method|
        class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{method}(*args, **options)
            with_retry { super }
          end
        RUBY
      end

      private def with_retry
        yield
      rescue Ractor::ClosedError
        raise unless reconnect?

        yield
      end

      private def reconnect?
        @ractor = @supervisor.ractor(@child_index)

        !!@ractor
      end
    end
  end
end
