require 'spec_helper'

describe Cany::Recipes::Sidekiq do
  let(:spec) do
    Cany::Specification.new do
      name 'test'
    end
  end
  let(:recipe) { spec.recipes.first }

  context '#binary' do
    context 'without configuration' do
      before do
        spec.setup do
          use :sidekiq
        end
      end

      it 'should launch sidekiq only with environment specification' do
        expect(recipe).to receive(:install_service).with(
          :sidekiq,
          %w(/usr/bin/test sidekiq --environment production),
          user: 'www-data', group: 'www-data'
        )
        recipe.inner = double('recipe')
        expect(recipe.inner).to receive(:binary)
        recipe.binary
      end
    end
  end

  context 'with queue names' do
    before do
      spec.setup do
        use :sidekiq do
          queue :name1
          queue :name2
        end
      end
    end

    it 'should launch sidekiq with the list of queues' do
      expect(recipe).to receive(:install_service).with(
        :sidekiq,
        %w(/usr/bin/test sidekiq --environment production --queue name1 --queue name2),
        user: 'www-data', group: 'www-data'
      )
      recipe.inner = double('recipe')
      expect(recipe.inner).to receive(:binary)
      recipe.binary
    end
  end

  context 'with defined user/group' do
    before do
      spec.setup do
        use :sidekiq do
          user 'user'
          group 'group'
        end
      end
    end

    it 'should launch sidekiq with as this user and group' do
      expect(recipe).to receive(:install_service).with(
                            :sidekiq,
                            %w(/usr/bin/test sidekiq --environment production),
                            user: 'user', group: 'group'
                        )
      recipe.inner = double('recipe')
      expect(recipe.inner).to receive(:binary)
      recipe.binary
    end
  end
end
