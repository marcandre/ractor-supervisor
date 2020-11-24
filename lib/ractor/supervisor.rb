# frozen_string_literal: true

require 'delegate'
require 'require_relative_dir'
require 'backports/3.0.0/ractor' if RUBY_VERSION < '3'

using RequireRelativeDir

require_relative_dir

class Ractor
  class Supervisor
    RESTARTS_ALLOWED = 5
    RESTART_WINDOW_IN_SECONDS = 4
    include Server

    def initialize(specs)
      @specs = specs
      @children = specs.children.map { |child_spec| Child.new(child_spec) }

      super
    end

    sync def ractors #: -> Array[Ractor]
      @children.map(&:ractor)
    end

    sync def ractor(
      index #: int
    )       #: -> Ractor
      @children.fetch(index).ractor
    end

    sync def inspect
      "#<#{self.class} #{@children.map(&:summary).join(', ')}>"
    end

    class Client
      def initialize(specs)
        @specs = specs

        super

        @initial_ractors = ractors

        Ractor.make_shareable(self)
      end

      def children
        @initial_ractors.map.with_index do |ractor, i|
          Supervised.new(supervisor: self, child_index: i, ractor: ractor)
        end
      end
    end

    # Children live server side and encapsulate the current state of a
    # given child (supervised ractor).
    class Child
      attr_reader :ractor, :specs, :last_restarts

      def initialize(child_specs)
        @specs = child_specs
        @ractor = @specs.start_ractor
        @restart_times = nil
        @restart_count = 0
        @last_result = nil
      end

      def restart
        now = Time.now
        @restart_times ||= []
        if @restart_times.size >= RESTARTS_ALLOWED
          last = @restart_times.shift
          # TODO: what about too many restarts?
          return decommission(:too_many_restarts) if last >= now + RESTART_WINDOW_IN_SECONDS
        end
        @restart_count += 1
        @restart_times << now
        @ractor = @specs.start_ractor
      end

      def decommission(data)
        @last_result = data
        @ractor = nil
      end

      def summary
        case
        when !@ractor
          "✖ (#{@last_result.inspect})"
        when !@restarts
          '⬆'
        else
          "⬆ [#{@restart_count}]"
        end
      end
    end

    private def receive
      ractor, data = begin
        Ractor.select(*@children.map(&:ractor).compact, self)
      rescue Ractor::RemoteError => e
        [e.ractor, e.cause]
      end
      return data if ractor == :receive

      monitor(child(ractor), data, !!error)
      nil
    end

    private def child(ractor)
      @children.find { |child| child.ractor == ractor }
    end

    private def monitor(child, data, is_remote_error)
      if errored?(child, is_remote_error)
        impacted(child).each(&:restart)
      else
        child.decommission(data)
      end
    end

    private def impacted(child) #: -> Array[Child]
      case specs.strategy
      when :one_for_one then [child]
      when :one_for_all then @children
      else
        cur_index = @children.index(child)
        @children[cur_index, @children.size]
      end
    end

    private def errored?(child, is_remote_error)
      case child.specs.restart
      when :permanent then true
      when :transient then is_remote_error
      else                 false
      end
    end
  end
end
