module Cany
  module Recipes
    class WebServer < Recipe
      def binary
        File.open File.join('debian', "#{spec.name}.upstart"), 'w' do |f|
          f.write "description  \"#{spec.description}\"\n"

          f.write "start on filesystem or runlevel [2345]\n"
          f.write "stop on runlevel [!2345]\n"

          f.write "respawn\n"
          f.write "respawn limit 10 5\n"
          f.write "umask 022\n"

          f.write "chdir /usr/share/#{spec.name}\n"

          f.write "pre-start script\n"
          f.write "\tmkdir -p /var/run/#{spec.name}\n"
          f.write "\tchown www-data /var/run/#{spec.name}\n"
          f.write "end script\n"

          f.write "exec su www-data --shell /usr/bin/#{spec.name} -- #{launch_command}\n"
        end
        inner.binary
      end
    end
  end
end
