require 'spec_helper'

describe Cany::Recipes::Bundler::Gem do
  let(:gem_name) { :bundler }
  subject { described_class.get gem_name }
  context '#get' do
    it 'should return always the same instance per gem' do
      should be_instance_of described_class
      expect(subject).to eq described_class.get gem_name
    end

    it 'should return different instances for different gems' do
      should_not eq described_class.get :bundler2
    end

    context 'returned gem instance' do
      context '\s gem_name' do
        subject { super().name }
        it { eq gem_name }
      end

      context '\s dependencies' do
        subject { super().dependencies }
        it 'should be empty per default' do
          should match_array []
        end
      end
    end
  end

  context '#specify' do
    subject { super().dependencies.first }
    let(:default) { subject.determine(:a, :b).first }
    context 'with added dependencies' do
      before do
        described_class.specify gem_name do
          depend 'hans_otto'
        end
      end
      it 'should added as runtime dependencies' do
        should be_runtime
        expect(default).to match_array [ 'hans_otto', nil]
      end
    end

  end
end
