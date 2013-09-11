require 'yaml'

module Cany
  module Recipes
    # This recipes runs the application with the thin web server. At the moment it installs only a
    # upstart start script. Other init scripts are planed (e.g. systemd for debian).
    class Thin < WebServer
      register_as :thin

      def launch_command
        "thin start -C /etc/#{spec.name}/thin.yml"
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
end
