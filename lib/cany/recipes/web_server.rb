module Cany
  module Recipes
    class WebServer < Recipe
      def binary
        recipe(:system).configure :service_pre_scripts, {
          mkdir_run: "mkdir /var/run/#{spec.name}",
          chown_run: "chown /var/run/#{spec.name}"
        }
        install_service name, ["/usr/bin/#{spec.name}"] + launch_command, user: 'www-data', group: 'www-data'
        inner.binary
      end
    end
  end
end
