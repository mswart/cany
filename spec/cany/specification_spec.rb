require 'spec_helper'

describe Cany::Specification do
  describe '#new' do
    it 'should have a name' do
      spec = Cany::Specification.new do
        name 'example'
      end
      expect(spec.name).to eq 'example'
    end
  end
end
