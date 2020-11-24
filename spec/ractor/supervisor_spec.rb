# frozen_string_literal: true

class Ractor
  class Supervisor
    RSpec.describe self do
      context 'given a spec built manually' do
        let(:first_child_spec) { ChildSpecs.new(Multiplier, 42) }
        let(:second_child_spec) { ChildSpecs.new(Multiplier, 42) }
        let(:specs) { Specs.new([first_child_spec, second_child_spec]) }
        subject(:supervisor) { Supervisor::Client.new(specs) }

        its(:inspect) { is_expected.to eq 'asdasd' }
      end
    end
  end
end
