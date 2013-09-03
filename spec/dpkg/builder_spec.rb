require 'spec_helper'
require 'cany/recipes/bundler'
require 'cany/recipes/rails'


describe Cany::Dpkg::Builder do
  let!(:dir) { Dir.mktmpdir }
  after { FileUtils.remove_entry dir}
  let(:spec) do
    s = Cany::Specification.new do
      name 'dpkg-creator-test'
      version '0.1'
      description 'Test Project'
      maintainer_name 'Hans Otto'
      maintainer_email 'hans.otto@example.org'
      website 'http://example.org'
      licence 'GPL-2+'
    end
    s.base_dir = dir
    s
  end
  let(:builder) { Cany::Dpkg::Builder.new(spec) }

  describe '#setup_recipes' do
    it 'should always setup debhelper recipe' do
      expect(Cany::Dpkg::DebHelperRecipe).to receive(:new).with(spec, nil)
      builder.setup_recipes
    end

    it 'should instance any used recipes' do
      spec.setup do
        use :bundler
        use :rails
      end
      expect(Cany::Dpkg::DebHelperRecipe).to receive(:new).ordered.with(spec, nil).and_call_original
      expect(Cany::Recipes::Bundler).to receive(:new).ordered.with(spec, kind_of(Cany::Dpkg::DebHelperRecipe)).and_call_original
      expect(Cany::Recipes::Rails).to receive(:new).ordered.with(spec, kind_of(Cany::Recipes::Bundler)).and_call_original
      builder.setup_recipes
    end
  end

  describe '#run' do
    it 'should setup recipes' do
      expect(builder).to receive(:setup_recipes).and_call_original
      builder.run 'clean'
    end

    it 'should call delegate the clean action to the loaded recipes' do
      expect_any_instance_of(Cany::Dpkg::DebHelperRecipe).to receive(:clean)
      builder.run 'clean'
    end
  end
end
