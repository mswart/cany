require 'yaml'

module Cany::Recipes
  # This recipes install the thin ruby web server. It is registered
  # and started as service.
  #
  # A simple thin configuration file (/etc/<application name>/thin.yml) is
  # created and can be adjusted to the user needs.
  #
  # @see http://code.macournoyer.com/thin/ The project website for more
  #   information about the project
  # @note The receives relies that the 'thin' gem is included in your Gemfile
  #   and therefore installed via bundler (and the bundler recipe).
  class Thin < WebServer
    register_as :thin

    def launch_command
      %W(thin start -C /etc/#{spec.name}/thin.yml")
    end

    def binary
      default_options = {
          'environment' => 'production',
          'socket' => "/var/run/#{spec.name}/sock",
          'pid' => "/var/run/#{spec.name}/thin.pid"
      }
      install_content "/etc/#{spec.name}/thin.yml", default_options.to_yaml
      super
    end
  end
end
