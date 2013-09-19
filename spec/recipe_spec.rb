require 'spec_helper'

describe Cany::Recipe do
  let(:spec) do
    Cany::Specification.new do
      name 'test-spec'
    end
  end
  let(:recipe) { Cany::Recipe.new(spec) }

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
end
