require 'spec_helper'

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

  describe '#run' do
    subject { builder.run 'clean' }
    it 'should set system_recipe' do
      expect(spec).to receive(:system_recipe=).with(kind_of(Cany::Dpkg::DebHelperRecipe)).and_call_original
      subject
    end

    it 'should setup recipes' do
      expect(spec).to receive(:setup_recipes).and_call_original
      subject
    end

    it 'should call delegate the clean action to the loaded recipes' do
      expect_any_instance_of(Cany::Dpkg::DebHelperRecipe).to receive(:clean)
      subject
    end
  end
end
