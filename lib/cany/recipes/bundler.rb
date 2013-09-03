module Cany
  module Recipes
    class Bundler < Cany::Recipe
      register_as :bundler

      def clean
        rmtree 'bundler'
        # rmtree 'vendor/bundle' -- do not remove gems, increase testing time
        inner.clean
      end

      def build
        ENV['GEM_PATH'] = 'bundler'
        ruby_bin 'gem', %w(install bundler --no-document --install-dir bundler --bindir bundler/bin)
        ruby_bin 'bundle', %w(install --deployment --without development test)
        inner.build
      end

      def binary
        install 'bundler', "/usr/share/#{spec.name}"
        install '.bundle', "/usr/share/#{spec.name}"
        install 'vendor/bundle', "/usr/share/#{spec.name}/vendor"
        inner.binary
      end
    end
  end
end
