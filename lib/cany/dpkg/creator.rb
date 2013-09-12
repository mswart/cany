require 'optparse'

module Cany
  module Dpkg
    class Creator
      attr_reader :spec
      def initialize(spec)
        @spec = spec
        @options = {}
      end

      def debian(*args)
        File.join spec.base_dir, 'debian', *args
      end

      def ruby_exe
        @options[:ruby_exe] || 'ruby'
      end

      def ruby_deb
        @options[:ruby_deb] || 'ruby'
      end

      def parse_opts(*args)
        @options = {}

        OptionParser.new do|opts|
          opts.on('--ruby-exe RUBY_EXE', 'Choose the ruby interpreter name (default is ruby)') do |exe|
            @options[:ruby_exe] = exe
          end

          opts.on('--ruby-deb RUBY_DEB', 'Choose the ruby package name (default is ruby)') do |deb|
            @options[:ruby_deb] = deb
          end

          opts.on('-r', '--ruby RUBY_EXE_DEB', 'Set ruby interpreter and package name') do |name|
            @options[:ruby_exe] = name
            @options[:ruby_deb] = name
          end

          opts.on('-h', '--help', 'Display this screen') do
            puts opts
            exit
          end
        end.parse *args
      end

      def run(*args)
        parse_opts *args

        Dir.mkdir debian
        create_compact
        create_source_format
        create_source_control
        create_copyright
        create_rules
        create_changelog
      end

      def create_source_format
        Dir.mkdir debian 'source'
        File.open(debian('source', 'format'), 'w') { |f| f.write '3.0 (native)' }
      end

      def create_compact
        File.open debian('compat'), 'w' do |f|
          f.write '8'
        end
      end

      def create_source_control
        File.open debian('control'), 'w' do |f|
          # write source package fields:
          f.write("Source: #{spec.name}\n")
          f.write("Section: ruby\n")
          f.write("Priority: optional\n")
          f.write("Maintainer: #{spec.maintainer_name} <#{spec.maintainer_email}>\n")
          f.write("Standards-Version: 3.9.2\n")
          f.write("Homepage: #{spec.website}\n")
          f.write("Build-Depends: debhelper (>= 7.0.50~), #{ruby_deb}, #{ruby_deb}-dev\n")

          # write binary package fields:
          f.write("\n")
          f.write("Package: #{spec.name}\n")
          f.write("Architecture: any\n")
          f.write("Depends: ${shlibs:Depends}, ${misc:Depends}, #{ruby_deb}\n")
          f.write("Description: #{spec.description}\n")
        end
      end

      def create_copyright
        File.open debian('copyright'), 'w' do |f|
          f.write("Format: http://dep.debian.net/deps/dep5\n")
          f.write("Upstream-Name: #{spec.name}\n\n")

          f.write("Files: *\n")
          f.write("Copyright: #{Time.now.year} #{spec.maintainer_name}\n")
          f.write("Licence: #{spec.licence}\n  [LICENCE TEXT]\n")
        end
      end

      def create_rules
        File.open debian('rules'), 'w' do |f|
          f.write("#!/usr/bin/make -f\n")
          f.write("export PATH := debian/bin:${PATH}\n")
          f.write("export GEM_PATH := debian/gems:${GEM_PATH}\n")
          # call cany for every target:
          f.write("%:\n")
          f.write("\t#{ruby_exe} -cS cany >/dev/null || #{ruby_exe} -S gem install --no-ri --no-rdoc --install-dir debian/gems --bindir debian/bin $${CANY_GEM:-cany}\n")
          f.write("\t#{ruby_exe} -S cany dpkg-builder $@\n")
          f.write("\noverride_dh_prep:\n")

          f.chmod(0755)
        end
      end

      def create_changelog
        File.open debian('changelog'), 'w' do |f|
          f.write "#{spec.name} (#{spec.version}-1) unstable; urgency=low\n"
          f.write "\n"
          f.write "  * Build with cany\n"
          f.write "\n"
          f.write " -- #{spec.maintainer_name} <#{spec.maintainer_email}>  #{Time.now.strftime "%a, %d %b %Y %H:%M:%S %z" }"
        end
      end
    end
  end
end
