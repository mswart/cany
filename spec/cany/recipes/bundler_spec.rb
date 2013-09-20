require 'spec_helper'

describe Cany::Recipes::Bundler do
  let(:spec) do
    Cany::Specification.new do
      name 'test'
      use :bundler
    end
  end
  let(:recipe) { spec.recipes[0] }
  before { recipe.prepare }

  context 'wrapper-script' do
    subject { recipe.wrapper_script }
    context 'without additional env variables' do
      it 'should contain GEM_PATH to find bundler' do
        expect(subject).to include('export GEM_PATH="bundler"')
      end
    end

    context 'with additional env variables' do
      before { recipe.configure :env_vars, RAILS_ENV: 'production' }
      it 'should contain all environment variables' do
        expect(subject).to include('export GEM_PATH="bundler"')
        expect(subject).to include('export RAILS_ENV="production"')
      end
    end
  end
end
