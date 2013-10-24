require 'spec_helper'

describe Cany::Recipes::Bundler do
  let(:spec) do
    Cany::Specification.new do
      name 'test'
    end
  end
  let(:recipe) { spec.recipes[0] }

  context 'wrapper-script' do
    before do
      spec.setup do
        use :bundler
      end
    end
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

  context 'bundle install' do

    context 'by default' do
      before do
        spec.setup do
          use :bundler
        end
        recipe.inner = double('recipe')
        expect(recipe.inner).to receive(:build)
      end
      let(:bundler_args) { %(bundle install --deployment --without development test) }
      it 'should ignore development and test' do
        @second = false
        expect(recipe).to receive(:ruby_bin) do |*args|
          if @second then
            expect(args.flatten).to eq bundler_args
          end
          unless @second then @second = true end
        end
        expect(recipe).to receive(:ruby_bin).with(any_args())
        recipe.build
      end
    end

    context 'with additional ignored group' do
      before do
        spec.setup do
          use :bundler do
            skip_group :integration
          end
        end
        recipe.inner = double('recipe')
        expect(recipe.inner).to receive(:build)
      end
      let(:bundler_args) { %w(bundle install --deployment --without development test integration) }
      it 'should ignore development, test and integration' do
        @second = false
        expect(recipe).to receive(:ruby_bin).twice do |*args|
          if @second then
            expect(args.flatten).to eq bundler_args
            @second = 6
          end
          unless @second then @second = true end
        end
        recipe.build
        expect(@second).to eq 6
      end
    end

    context 'with reenabled group' do
      before do
        spec.setup do
          use :bundler do
            skip_group :development, false
          end
        end
        recipe.inner = double('recipe')
        expect(recipe.inner).to receive(:build)
      end
      let(:bundler_args) { %w(bundle install --deployment --without test) }
      it 'should ignore only left over one' do
        @second = false
        expect(recipe).to receive(:ruby_bin).twice do |*args|
          if @second then
            expect(args.flatten).to eq bundler_args
            @second = 6
          end
          unless @second then @second = true end
        end
        recipe.build
        expect(@second).to eq 6
      end
    end
  end
end
