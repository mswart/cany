module Cany::Recipes
  # This recipes installs Sidekiq
  #   "Simple, efficient, background processing in Ruby"
  # Sidekiq is registered as service and so automatically started.
  # @see http://sidekiq.org/ The official website for more information.
  # @node The recipe relies that 'sidekiq' is listed inside your Gemfile and
  #   therefore installed via the 'bundler' recipe.
  class Sidekiq < Cany::Recipe
    register_as :sidekiq

    attr_accessor :queues

    def initialize(*args)
      @queues = []
      super
    end

    class DSL < Cany::Recipe::DSL
      def queue(name)
        @recipe.queues << name
      end
    end

    def binary
      install_service name, %W(/usr/bin/#{spec.name} sidekiq) + sidekiq_args, user: 'www-data', group: 'www-data'
      inner.binary
    end

    def sidekiq_args
      args = %w(--environment production)
      if queues.any?
        args << '--queue'
        args << queues.join(',')
      end
      args
    end
  end
end
