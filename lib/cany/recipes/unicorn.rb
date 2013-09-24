module Cany::Recipes
  # This recipes install the Unicorn Rack HTTP server. It is registered
  # and started as service.
  #
  # @see http://unicorn.bogomips.org/ The project website for more
  #   information about the project
  # @note The receives relies that the 'unicorn' gem is included in your
  #   Gemfile and therefore installed via bundler (and the bundler recipe).
  class Unicorn < WebServer
    register_as :unicorn

    def launch_command
      %W(unicorn start -c /etc/#{spec.name}/unicorn.rb -E production)
    end
  end
end
