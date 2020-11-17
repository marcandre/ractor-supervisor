# frozen_string_literal: true

module Ractor
  class Supervisor
    ChildSpecs = Struct.new(:constructor, :arguments, :restart)

    class ChildSpecs
      RESTART = [
        :permanent, # the child process is always restarted.
        :transient, # the child process is restarted only if it terminates because of an Exception
        :temporary, # the child process is never restarted, even RemoteErrors are regarded as successful
      ].freeze

      # (Class, *args: any, method: sym)
      # (*args: any) { |*args: any| }
      def initialize(*args, restart: :permanent, method: :run, &constructor)
        check_args(args)

        constructor ||= class_constructor(args, method)

        super(constructor, args, restart)

        Ractor.make_shareable(self)
      end

      def start
        Ractor.new(arguments, &constructor)
      end

      private def check_args(args)
        return unless args.select! { |x| Ractor.shareable?(x) }

        bad = args.map(&:inspect).join(', ')
        raise ArgumentError, "Some arguments are not shareable: #{bad}"
      end

      private def class_constructor(args, method)
        raise TypeError, "Excepted Class, got #{args.first.class}" unless args.first.is_a?(Class)

        args.insert(1, method)
        ->(klass, method, *args) do
          obj = klass.new(*args)
          obj.__send__(method) if method
          obj
        end
      end
    end
  end
end
