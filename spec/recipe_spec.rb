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
end
