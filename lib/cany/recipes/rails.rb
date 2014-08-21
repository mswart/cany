module Cany
  module Recipes
    class Rails < Recipe
      register_as :rails
      hook :env

      class DSL < Recipe::DSL
        delegate :compile_assets, :assets_env
      end

      attr_accessor :compile_assets, :assets_env

      def initialize(*args)
        @compile_assets = true
        @assets_env = 'production'
        super
      end

      def clean
        rmtree 'tmp', 'public/assets'
        inner.clean
      end

      def prepare
        recipe(:bundler).configure :env_vars, RAILS_ENV: 'production'
      end

      def build
        run_hook :env, :before
        if compile_assets
          ENV['RAILS_ENV'] = assets_env
          ruby_bin 'bundle', 'exec', 'rake', 'assets:precompile'
        end
        ENV['RAILS_ENV'] = 'production'
        inner.build
      end

      def binary
        run_hook :env, :after
        %w(app bin config.ru db Gemfile Gemfile.lock lib public Rakefile vendor).each do |item|
          install item, "/usr/share/#{spec.name}" if File.exists? item
        end

        Dir.foreach('config') do |entry|
          next if %w(. ..).include? entry
          install File.join('config', entry), "/etc/#{spec.name}"
        end
        install_link "/etc/#{spec.name}", "/usr/share/#{spec.name}/config"

        install_dir "/etc/#{spec.name}"
        install_dir "/var/tmp/#{spec.name}"
        install_dir "/var/log/#{spec.name}"

        install_link "/var/log/#{spec.name}", "/usr/share/#{spec.name}/log"
        install_link "/var/tmp/#{spec.name}", "/usr/share/#{spec.name}/tmp"
        inner.binary
      end
    end
  end
end
