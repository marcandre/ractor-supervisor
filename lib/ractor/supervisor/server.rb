# frozen_string_literal: true

module Ractor
  class Supervisor
    module Server
      EXCEPTION = Object.new.freeze

      class Client
        attr_reader :ractor

        def initialize(*args, **options)
          ractor = Ractor.new(self.class, *args, options.freeze) do |klass, *args, options|
            server = klass.new(*args, **options)
            server.main_loop
          end
          @ractor = ractor
        end
      end

      def main_loop
        loop do
          process receive
        end
      end

      private def receive
        Ractor.receive
      end

      private def process(data)
        cmd, args, options, client_ractor = data
        return unless cmd

        begin
          result = __send__ cmd, *args, **options
        rescue StandardError => e
          client_ractor&.send(EXCEPTION, e, move: true)
          # TODO: what to do for async calls?
          return
        end
        client_ractor&.send(result, move: true)
      end

      module ClassMethods
        def sync(method_name)
          define_sync_call(method_name)
          method_name
        end

        def async(method_name)
          define_async_call(method_name)
          method_name
        end

        def start(*args, **options)
          self::Client.new(*args, **options)
        end

        private def inherited(base)
          base.class_eval <<~RUBY, __FILE__, __LINE__ + 1
            extend Server::ClassMethods

            class Client < superclass::Client
              ServerCalls = Module.new
              include ServerClass
            end
          RUBY

          super
        end

        private def define_async_call(method_name)
          self::Client::ServerCalls.module_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{method_name}(*args, **options)
              ractor.send(:#{method_name}, args.freeze, options.freeze)
            end
          RUBY
        end

        private def define_sync_call(method_name)
          self::Client::ServerCalls.module_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{method_name}(*args, **options)
              cur = Ractor.current
              ractor.send(:#{method_name}, args.freeze, options.freeze, cur)
              result = cur.receive
              raise cur.receive if EXCEPTION == result

              result
            end
          RUBY
        end
      end

      define_singleton_method :included, ClassMethods.instance_method(:inherited)
    end
  end
end
