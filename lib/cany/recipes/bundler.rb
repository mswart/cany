module Cany
  module Recipes
    class Bundler < Cany::Recipe
      register_as :bundler
      option :env_vars, GEM_PATH: 'bundler'
      option :skip_groups, development: true, test: true
      option :clean_gems, nil => :whitelist

      class DSL < Recipe::DSL
        def skip_group(name, skip=true)
          @recipe.configure :skip_groups, name => skip
        end
      end

      def clean
        rmtree 'bundler'
        inner.clean
      end

      def create(creator)
        require 'bundler'
        lock_path = File.join(spec.base_dir, 'Gemfile.lock')
        if File.exists? lock_path
          lock = ::Bundler::LockfileParser.new File.read lock_path
          lock.specs.each do |spec|
            Gem.get(spec.name.to_sym).dependencies.each do |dep|
              depend dep
            end
          end
        end
      end

      def build
        ENV['GEM_PATH'] = 'bundler'
        ENV['PATH'] = 'bundler/bin:' + ENV['PATH']
        ENV['GEM_HOME'] = File.absolute_path('debian/gems')
        old_home = ENV['HOME']
        ENV['HOME'] = File.absolute_path('debian')
        ruby_bin 'gem', %w(install bundler --no-ri --no-rdoc --install-dir bundler --bindir bundler/bin)
        ENV['HOME'] = old_home
        ruby_bin 'bundle', %w(install --deployment --without), skipped_groups
        clear_gem_dirs
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

      def skipped_groups
        option(:skip_groups).select do |option, skipped|
          skipped
        end.map do |name, _|
          name.to_s
        end
      end

      def clear_gem_dirs
        Dir.glob('vendor/bundle/ruby/*/specifications/*').each do |gemspec_file|
          gemspec = ::Gem::Specification.load gemspec_file
          kind = option(:clean_gems)[gemspec.name] || option(:clean_gems)[nil]
          case kind
          when :whitelist
            clear_gem_dir gemspec
          when false
            # do nothing
          else
            raise RuntimeError.new "Unknown clean kind #{kind}"
          end
        end
      end

      def clear_gem_dir(gemspec)
        puts "  clearing #{gemspec.name} ..."
        Dir.new(gemspec.gem_dir).each do |entry|
          next if %w{. ..}.include? entry
          if gemspec.bin_dir.include? entry
            puts "    keep bin dir #{gemspec.gem_dir}/#{entry}"
          elsif gemspec.require_paths.include? entry
            puts "    keep require dir #{gemspec.gem_dir}/#{entry}"
          elsif %w{data vendor app}.include? entry # some generic exceptions
            puts "    keep #{gem_spec.gem_dir}/#{entry} as exception"
          else
            puts "    removing unused dir/file: #{gemspec.gem_dir}/#{entry} ..."
            FileUtils.rm_rf File.join(gemspec.gem_dir, entry)
          end
        end
      end
    end
  end
end
