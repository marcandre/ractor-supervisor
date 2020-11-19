# frozen_string_literal: true
require 'delegate'
require 'require_relative_dir'
using RequireRelativeDir

require_relative_dir

module Ractor
  class Supervisor
    using Internals


    STRATEGIES = %i[one_for_one one_for_all rest_for_one].freeze
    def initialize(specs)
      @specs = specs
    end

    def supervise(*init_args, restart: nil, &block)
      @specs << Child.new(init_args, restart, block)
    end

    def start_child(index)
      specs.children[index]
    end
  end
end
