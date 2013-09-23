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

    it 'should have a licence' do
      spec = Cany::Specification.new do
        licence 'MIT'
      end
      expect(spec.licence).to eq 'MIT'
    end

    it 'should have a version' do
      spec = Cany::Specification.new do
        version '0.1'
      end
      expect(spec.version).to eq '0.1'
    end

    it 'should be able to include recipes' do
      spec = Cany::Specification.new do
        use :bundler
      end
      expect(spec.recipes.size).to eq 1
      expect(spec.recipes[0]).to be_instance_of(Cany::Recipes::Bundler)
    end

    it 'should accept a block for own build steps' do
      spec = Cany::Specification.new do
        build do
          install 'hans', 'otto'
        end
      end
      expect(spec.build).to be_a_kind_of Proc
    end

    it 'should accept a block for own build steps' do
      spec = Cany::Specification.new do
        binary do
          install 'hans', 'otto'
        end
      end
      expect(spec.binary).to be_a_kind_of Proc
    end
  end

  context 'with a required cany version' do
    let(:spec) { Cany::Specification.new { name 'test-spec' } }
    subject { spec }

    it 'pass if it matches cany\'s version' do
      expect(Cany::VERSION).to receive(:to_s).at_least(:once).and_return '0.1.1'
      spec.setup { require_cany '~> 0.1' }
    end

    it 'fail if cany\'s version is to old' do
      expect(Cany::VERSION).to receive(:to_s).at_least(:once).and_return '0.0.1'
      expect { spec.setup { require_cany '~> 0.1' } }.to raise_exception Cany::UnsupportedVersion, /.*require.*"~> 0\.1" but .* "0.0.1"/
    end

    it 'fail if cany\'s version is to new' do
      expect(Cany::VERSION).to receive(:to_s).at_least(:once).and_return '1.0'
      expect { spec.setup { require_cany '~> 0.1' } }.to raise_exception Cany::UnsupportedVersion, /.*require.*"~> 0\.1" but .* "1.0"/
    end
  end

  context '#build_dependencies' do
    let(:spec) { described_class.new {} }
    subject { spec.build_dependencies }
    let(:build_dep1) { Cany::Dependency.new situations: :build }
    let(:runtime_dep1) { Cany::Dependency.new situations: :runtime }
    let(:both_dep1) { Cany::Dependency.new situations: [:build, :runtime] }

    it { should eq [] }

    context 'with added build dependencies' do
      before { spec.dependencies << build_dep1 }

      it 'should include these deps' do
        should match_array [build_dep1]
      end
    end

    context 'with added runtime dependencies' do
      before { spec.dependencies << runtime_dep1 }
      it 'should not include' do
        should match_array []
      end
    end

    context 'with added build + runtime dependencies' do
      before { spec.dependencies << both_dep1 }

      it 'should include this dep' do
        should match_array [both_dep1]
      end
    end
  end

  context '#runtime_dependencies' do
    let(:spec) { described_class.new {} }
    subject { spec.runtime_dependencies }
    let(:build_dep1) { Cany::Dependency.new situations: :build }
    let(:runtime_dep1) { Cany::Dependency.new situations: :runtime }
    let(:both_dep1) { Cany::Dependency.new situations: [:build, :runtime] }

    it { should eq [] }

    context 'with added build dependencies' do
      before { spec.dependencies << build_dep1 }

      it 'should not include' do
        should match_array []
      end
    end

    context 'with added runtime dependencies' do
      before { spec.dependencies << runtime_dep1 }
      it 'should include these deps' do
        should match_array [runtime_dep1]
      end
    end

    context 'with added build + runtime dependencies' do
      before { spec.dependencies << both_dep1 }

      it 'should include this dep' do
        should match_array [both_dep1]
      end
    end
  end
end
