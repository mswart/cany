module Cany
  module Recipes
    class Bundler < Cany::Recipe
      register_as :bundler
      option :env_vars

      def clean
        rmtree 'bundler'
        # rmtree 'vendor/bundle' -- do not remove gems, increase testing time
        inner.clean
      end

      def prepare
        configure :env_vars, GEM_PATH: 'bundler'
      end

      def build
        ENV['GEM_PATH'] = 'bundler'
        ENV['PATH'] = 'bundler/bin:' + ENV['PATH']
        ruby_bin 'gem', %w(install bundler --no-ri --no-rdoc --install-dir bundler --bindir bundler/bin)
        ruby_bin 'bundle', %w(install --deployment --without development test)
        inner.build
      end

      def binary
        install 'bundler', "/usr/share/#{spec.name}"
        install '.bundle', "/usr/share/#{spec.name}"
        install 'vendor/bundle', "/usr/share/#{spec.name}/vendor"
        install_content "/usr/bin/#{spec.name}", wrapper_script
        inner.binary
      end

      def wrapper_script
        content = [ '#!/bin/sh', "cd /usr/share/#{spec.name}" ]
        option(:env_vars).each do |name, value|
          content << "export #{name}=\"#{value}\""
        end
        content += [ "exec /usr/share/#{spec.name}/bundler/bin/bundle exec \"$@\"", '' ]
        content.join "\n"
      end
    end
  end
end
