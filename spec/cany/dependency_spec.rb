require 'spec_helper'

describe Cany::Dependency do
  let(:dep) { Cany::Dependency.new }
  subject { dep.determine(distro, release) }
  let(:distro) { :ubuntu }
  let(:release) { :precise }

  context 'without defined packages' do
    it 'should return a empty list' do
      expect(subject).to match_array []
    end
  end

  context 'without distro information' do
    context 'and a simple default package' do
      before { dep.define_default('example') }
      it 'should return the packages and nil as version' do
        expect(subject).to match_array [['example', nil]]
      end
    end

    context 'and a default package with version' do
      before { dep.define_default('example', '>= 1.7') }
      it 'should return the packages and its version' do
        expect(subject).to match_array [['example', '>= 1.7']]
      end
    end

    context 'with multiple default packages' do
      before do
        dep.define_default('example')
        dep.define_default('otto')
      end
      it 'should return all default packages' do
        expect(subject).to match_array [['otto', nil], ['example', nil]]
      end
    end
  end

  context 'with distribution default packages' do
    before { dep.define_on_distro(distro, 'hans') }

    it 'should return distro packages' do
      expect(subject).to match_array [['hans', nil]]
    end

    context 'and with default packages' do
      before { dep.define_default('default') }
      it 'should only return distro package' do
        expect(subject).to match_array [['hans', nil]]
      end
    end

    context 'and a second distro package' do
      before { dep.define_on_distro(distro, 'otto') }
      it 'should return both packages' do
        expect(subject).to match_array [['hans', nil], ['otto', nil]]
      end
    end
  end

  context 'with distribution release information' do
    before { dep.define_on_distro_release(distro, release, 'distrorelease') }
    it 'should return distro release packages' do
      expect(subject).to match_array [['distrorelease', nil]]
    end

    context 'with additional distrorelease packages with version' do
      before { dep.define_on_distro_release(distro, release, 'add', '!= 2.8') }
      it 'should return both packages with its version or nil' do
        expect(subject).to match_array [['distrorelease', nil], ['add', '!= 2.8']]
      end
    end

    context 'with distro packages' do
      before { dep.define_on_distro(distro, 'other') }
      it 'should return only distrorelease packages' do
        expect(subject).to match_array [['distrorelease', nil]]
      end
    end
  end

  context 'situations property' do
    subject { dep.situations }
    it 'should be runtime per default' do
      should match_array [:runtime]
    end

    context 'set to single value' do
      before { dep.situations = :build }
      it 'should convert them to an array' do
        should match_array [:build]
      end
    end

    context 'set to multiple values' do
      before { dep.situations = [:build, :runtime] }
      it 'should remain the array' do
        should match_array [:build, :runtime]
      end
    end

    context 'accessabled via shortcut properties' do
      subject { dep }
      it 'should be runtime and not build per default' do
        should be_runtime
        should_not be_build
      end

      context 'with changed value' do
        before { dep.situations = [:build, :hans] }
        it 'should behave accordingly' do
          should_not be_runtime
          should be_build
        end
      end
    end
  end
end
