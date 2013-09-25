module Cany::Recipes
  # @!attribute user
  #   @return [String, nil] The user name as which the web server process should
  #      executed
  # @!attribute group
  #   @return [String, nil] The group name as which the web server process should
  #      executed
  class WebServer < Cany::Recipe
    attr_accessor :user, :group
    class DSL < Cany::Recipe::DSL
      delegate :user, :group
    end

    def initialize(*args)
      @user = 'www-data'
      @group = 'www-data'
      super
    end

    def binary
      recipe(:system).configure :service_pre_scripts, {
        mkdir_run: "mkdir -p /var/run/#{spec.name}",
        chown_run: "chown #{user}:#{group} /var/run/#{spec.name}"
      }
      install_service name, ["/usr/bin/#{spec.name}"] + launch_command, user: user, group: group
      inner.binary
    end
  end
end
