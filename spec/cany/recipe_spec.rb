require 'spec_helper'

describe Cany::Recipe do
  let(:spec) do
    Cany::Specification.new do
      name 'test-spec'
    end
  end
  let(:recipe) { Cany::Recipe.new(spec) }
  let(:test_recipe) { TestRecipe.new(spec) }

  describe '#exec' do
    it 'should execute system command' do
      expect(recipe).to receive(:system).with('a', 'b', 'c').and_return true
      recipe.exec_('a', 'b', 'c')
    end

    it 'should flatten the passed arguments' do
      expect(recipe).to receive(:system).with('a', 'b', 'c').and_return true
      recipe.exec_(%w(a b c))
    end

    it 'should flatten the passed arguments #2' do
      expect(recipe).to receive(:system).with('a', 'b', 'c', 'd', 'e', 'f').and_return true
      recipe.exec_('a', %w(b c), 'd', ['e', 'f'])
    end

    it 'should raise an exception on failed program execution' do
      expect { recipe.exec_ 'false' }.to raise_exception Cany::CommandExecutionFailed, /Could not execute.*false/
    end

    it 'should raise an exception on failed program execution with args' do
      expect { recipe.exec_ %w(false 4) }.to raise_exception Cany::CommandExecutionFailed, /Could not execute.*false 4/
    end
  end

  describe 'hook handling' do
    it 'should raise an error on an unknown hooks' do
      expect { recipe.run_hook :test, :after }.to raise_exception Cany::UnknownHook, /Unknown hook.*test/
    end

    it 'should handle hooks without defined block' do
      test_recipe.run_hook :test_hook, :after
    end

    it 'should passed block for hook' do
      expect(Cany).to receive(:hook_executed)
      spec.setup do
        use :test_recipe do
          before :test_hook do
            Cany.hook_executed
          end
        end
      end
      spec.recipes[0].run_hook :test_hook, :before
    end

    it 'hook should be limited to recipe' do
      expect do
        spec.setup do
          use :bundler do
            before :test_hook do
              Dummy.hook_executed
            end
          end
        end
      end.to raise_exception Cany::UnknownHook, /Unknown hook.*test_hook/
    end
  end

  describe 'recipe configure options' do
    let(:option_name) { :test_conf }
    subject { test_recipe.option option_name }

    context 'with an undefined config' do
      let(:option_name) { :unknown_option }
      it 'should raise an exception' do
        expect { subject }.to raise_exception Cany::UnknownOption, /Unknown option .*unknown_option/
      end
    end

    context 'with a defined config' do
      let(:recipe2) { Cany::Recipe.new(spec) }
      it 'should be initialized with {} per default' do
        expect(subject).to eq Hash.new
      end

      context 'should be configurable' do
        before do
          test_recipe.configure :test_conf, env: 'production'
        end
        it { expect(subject).to eq(env: 'production') }
      end

      context 'options should be merged between multiple calls' do
        before do
          test_recipe.configure :test_conf, env: 'production'
          test_recipe.configure :test_conf, env2: 'hans'
        end
        it { expect(subject).to eq(env: 'production', env2: 'hans') }
      end
    end
  end

  describe '#recipe' do
    let(:other_recipe) { :test_recipe }
    subject { recipe.recipe other_recipe }
    context 'to access other loaded recipe' do
      before { spec.setup { use :test_recipe } }
      it 'should return the recipe instance from this specification' do
        expect(subject).to be spec.recipes.first
      end
    end

    context 'to access an unloaded recipe' do
      it 'should raise an exception' do
        expect { subject }.to raise_exception Cany::UnloadedRecipe, /[Rr]ecipe.+test_recipe.+no.+loaded/
      end
    end

    context 'to access an unknown recipe' do
      let(:other_recipe) { :unknown_recipe }
      it 'should raise an exception' do
        expect { subject }.to raise_exception Cany::UnknownRecipe, /[Rr]ecipe.+unknown_recipe.+not.+registered./
      end
    end
  end

  describe '#depend' do
    subject { spec.dependencies }

    context 'without any call' do
      it 'it should be empty' do
        should eq []
      end
    end

    context 'with a single string' do
      subject { super().first }

      context 'without other options' do
        before { recipe.depend 'hans-otto-lib' }
        it 'should converted into a runtime dependency object' do
          should be_instance_of Cany::Dependency
          should be_runtime
          should_not be_build
        end
      end

      context 'with situation option' do
        before { recipe.depend 'hans-otto-lib', situation: :build }
        it 'should converted into a runtime dependency object' do
          should be_instance_of Cany::Dependency
          should_not be_runtime
          should be_build
        end
      end

      context 'with a version option' do
        before { recipe.depend 'hans-otto', version: '>= 4' }
        it 'should be convert' do
          should be_instance_of Cany::Dependency
          expect(subject.determine(:a, :b)).to match_array [['hans-otto', '>= 4']]
        end
      end
    end
    context 'with a dependency object' do
      let(:dep) { Cany::Dependency.new }
      subject { super().first }
      before { recipe.depend dep }
      it 'should be passed without modification' do
        should eq dep
      end
    end
  end

  context '#name' do
    context 'on an unregistered recipe' do
      subject { recipe.name }
      it 'should raise a NoMethodError' do
        expect { subject }.to raise_exception NoMethodError
      end
    end

    context 'on a registered recipe' do
      subject { test_recipe.name }
      it 'should return its registered name' do
        should eq :test_recipe
      end
    end
  end
end
