require 'spec_helper'

describe Cany::Recipes::Rails do
  describe 'DSL' do
    let(:spec) do
      Cany::Specification.new do
        name 'test'
      end
    end
    let(:recipe) { spec.recipes[0] }

    it 'should compile assets by default' do
      spec.setup do
        use :rails
      end
      expect(recipe.compile_assets).to eq true
    end

    it 'should be able to disable assets compilation' do
      spec.setup do
        use :rails do
          compile_assets false
        end
      end
      expect(recipe.compile_assets).to eq false
    end
  end
end
