module Cany::Recipes
  # This recipes installs Sidekiq
  #   "Simple, efficient, background processing in Ruby"
  # Sidekiq is registered as service and so automatically started.
  # @see http://sidekiq.org/ The official website for more information.
  # @note The recipe relies that 'sidekiq' is listed inside your Gemfile and
  #   therefore installed via the 'bundler' recipe.
  #
  # @!attribute queues
  #   @return [Array<String>, nil] An (optional) list of queue names sidekiq
  #     should listen on
  # @!attribute user
  #   @return [String, nil] The user name as which the sidekiq process should
  #      executed
  # @!attribute group
  #   @return [String, nil] The group name as which the sidekiq process should
  #      executed
  class Sidekiq < Cany::Recipe
    register_as :sidekiq

    attr_accessor :queues
    attr_accessor :user, :group

    def initialize(*args)
      @queues = []
      @user = 'www-data'
      @group = 'www-data'
      super
    end

    class DSL < Cany::Recipe::DSL
      def queue(name)
        @recipe.queues << name
      end
      delegate :user, :group
    end

    def binary
      install_service name, %W(/usr/bin/#{spec.name} sidekiq) + sidekiq_args, user: user, group: group
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
