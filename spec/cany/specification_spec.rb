require 'spec_helper'

describe Cany::Specification do
  describe '#new' do
    it 'should have a name' do
      spec = Cany::Specification.new do
        name 'example'
      end
      expect(spec.name).to eq 'example'
    end

    it 'should have a description' do
      spec = Cany::Specification.new do
        description 'Test hans otto project'
      end
      expect(spec.description).to eq 'Test hans otto project'
    end

    it 'should have a maintainer name' do
      spec = Cany::Specification.new do
        maintainer_name 'Otto Hans'
      end
      expect(spec.maintainer_name).to eq 'Otto Hans'
    end

    it 'should have a maintainer email' do
      spec = Cany::Specification.new do
        maintainer_email 'hans.otto@example.org'
      end
      expect(spec.maintainer_email).to eq 'hans.otto@example.org'
    end

    it 'should have a website' do
      spec = Cany::Specification.new do
        website 'http://example.org/~hans.otto/'
      end
      expect(spec.website).to eq 'http://example.org/~hans.otto/'
    end
  end
end
