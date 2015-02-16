require 'spec_helper'
require 'yaml'

describe Cany::Recipes::Thin do
  let(:setup) { proc { use :thin } }
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
                              :thin,
                              %w(/usr/bin/test thin start --config /etc/test/thin.yml),
                              user: 'www-data', group: 'www-data'
                          )
        data = {
          'environment' => 'production',
          'socket' => "/var/run/test/sock",
          'pid' => '/var/run/test/thin.pid'
        }
        expect(recipe).to receive(:install_content).with '/etc/test/thin.yml', YAML.dump(data)
        subject
        expect(pre_scripts).to eq({
                                      mkdir_run: 'mkdir -p /var/run/test',
                                      chown_run: 'chown www-data:www-data /var/run/test'
                                  })
      end
    end

    context 'with defined user/group' do
      let(:setup) { proc { use(:thin) { user 'user'; group 'group' } } }

      it 'should launch unicorn with as this user and group' do
        expect(recipe).to receive(:install_service).with(
                              :thin,
                              %w(/usr/bin/test thin start --config /etc/test/thin.yml),
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
