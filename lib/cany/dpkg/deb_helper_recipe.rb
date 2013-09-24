require 'erb'

module Cany::Dpkg
  class DebHelperRecipe < Cany::Recipe
    register_as :deb_helper

    option :service_pre_scripts

    def initialize(*args)
      super *args
      @services = {}
      @pre_scripts = []
      @log = File.read debhelper_log if File.exists? debhelper_log
    end

    def create(creator)
      depend 'debhelper', version: '>= 7.0.50~', situation: :build
      depend '${shlibs:Depends}'
      depend '${misc:Depends}'
      depend creator.ruby_deb, situation: [:build, :runtime]
      depend creator.ruby_deb + '-dev', situation: :build
    end

    def clean
      exec %w(dh clean)
    end

    def build
      instance_eval &spec.build if spec.build
      exec %w(dh build)
    end

    def binary
      instance_eval &spec.binary if spec.binary
      install_base_service
      install_services
      File.write debhelper_log, @log if File.exists? debhelper_log
      exec %w(dh binary)
    end

    def install_service(name, command, opts={})
      opts = {user: 'root', group: 'root'}.merge opts
      opts[:command] = command
      @services[name] = opts
    end

    def install_services
      @services.each do |name, opts|
        File.write debian("#{spec.name}.#{spec.name}-#{name}.upstart"), render(<<-EOF.gsub(/^ {10}/, ''), opts.merge(name: name))
          description "<%= spec.description %> - <%= name %>"

          start on started <%= spec.name %>
          stop on stopping <%= spec.name %>

          respawn
          respawn limit 10 5
          umask 022

          chdir /usr/share/<%= spec.name %>

          <% if user %>
          setuid <%= user %>
          <% end %>
          <% if group %>
          setgid <%= group %>
          <% end %>

          exec <%= command %>
        EOF
        Cany.logger.warn name
        exec %w{dh_installinit --name}, "#{spec.name}-#{name}"
      end
    end

    def install_base_service
      File.write debian("#{spec.name}.upstart"), render(<<-EOF.gsub(/^ {8}/, ''))
        description "#{spec.description}"

        start on filesystem or runlevel [2345]
        stop on runlevel [!2345]

        respawn
        respawn limit 10 5
        umask 022

        pre-start script
        <% pre_scripts.each do |k, command| %>
          <%= command %>
        <% end %>
        end script

        exec sleep 1d
      EOF
    end

    private
    def render(template, opts={})
      def opts.method_missing(name)
        self[name]
      end
      opts[:spec] = spec
      opts[:pre_scripts] = option :service_pre_scripts
      ERB.new(template, nil, '<>').result opts.instance_eval { binding }
    end

    def debian(*args)
      File.join('debian', *args)
    end

    def debhelper_log
      debian("#{spec.name}.debhelper.log")
    end
  end
end
