# frozen_string_literal: true

module Ractor
  class Supervisor
    ChildSpecs = Struct.new(:constructor, :arguments, :restart)

    class ChildSpecs
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
        if args.select! { |x| Ractor.shareable?(x) }
          bad = args.map(&:inspect).join(', ')
          raise ArgumentError, "Some arguments are not shareable: #{bad}"
        end
      end

      private def class_constructor(args, method)
        raise TypeError, "Excepted Class, got #{args.first.class}" unless args.first.is_a?(Class)

        args.insert(1, method)
        Proc.new do |klass, method, *args|
          klass.new(*args).__send__(
        end
      end
    end
  end
end
