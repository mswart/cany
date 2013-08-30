require 'spec_helper'

describe Cany do
  context '#setup' do
    it 'should require a .canspec file' do
      expect { Cany::setup File.expand_path('../fixtures/empty', __FILE__) }.to raise_error(Cany::MissingSpecification)
    end
  end

  it 'should stop on multiple .canspec files' do
    expect { Cany::setup File.expand_path('../fixtures/multiple', __FILE__) }.to raise_error Cany::MultipleSpecifications, /Multiple canspec found in .*/
  end

  it 'should load a .canspec file' do
    spec = Cany::setup File.expand_path('../fixtures/single', __FILE__)
    expect(spec).to be_an_instance_of Cany::Specification
    expect(spec.name).to eq 'single-test'
    expect(spec.base_dir).to eq File.expand_path('../fixtures/single', __FILE__)
  end
end
