require 'spec_helper'

describe Cany::Recipes::Unicorn do
  let(:setup) { proc { use :unicorn } }
  let(:spec) do
    Cany::Specification.new do
      name 'test'
    end
  end
  let(:recipe) { spec.recipes.first }
  let(:system_recipe) { Cany::Dpkg::DebHelperRecipe.new(spec) }
  let(:pre_scripts) { system_recipe.option(:service_pre_scripts) }
  subject { recipe.binary }

  context '#binary' do
    before do
      spec.setup &setup
      spec.system_recipe = system_recipe
      recipe.inner = double('recipe')
      expect(recipe.inner).to receive(:binary)
    end

    context 'without configuration' do

      it 'should launch unicorn only with environment specification and config file' do
        expect(recipe).to receive(:install_service).with(
                              :unicorn,
                              %w(/usr/bin/test unicorn --config-file /etc/test/unicorn.rb --env production),
                              user: 'www-data', group: 'www-data'
                          )
        subject
        expect(pre_scripts).to eq({
                                      mkdir_run: 'mkdir -p /var/run/test',
                                      chown_run: 'chown www-data:www-data /var/run/test'
                                  })
      end
    end

    context 'with defined user/group' do
      let(:setup) { proc { use(:unicorn) { user 'user'; group 'group' } } }

      it 'should launch unicorn with as this user and group' do
        expect(recipe).to receive(:install_service).with(
                              :unicorn,
                              %w(/usr/bin/test unicorn --config-file /etc/test/unicorn.rb --env production),
                              user: 'user', group: 'group'
                          )
        subject
        expect(pre_scripts).to eq({
                                      mkdir_run: 'mkdir -p /var/run/test',
                                      chown_run: 'chown user:group /var/run/test'
                                  })
      end
    end
  end
end
