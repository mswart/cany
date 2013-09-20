module Cany
  module Dpkg
    # This class does the real job. It is called for every dpkg build step to build the package.
    # An instance is created on every execution. The package specification is passed as option to
    # the initializer. Afterwards the run method is called to execute the wanted build step. The
    # first parameter specifies the build step name (clean, build, binary).
    # This method uses recipes instances to do the job itself.
    class Builder
      attr_reader :spec
      def initialize(spec)
        @spec = spec
      end

      def debian(*args)
        File.join spec.base_dir, 'debian', *args
      end

      # This method is called to do the actual work
      # @api public
      # @param [String] build_step_name The name of the dpkg build step (clean, build, binary)
      def run(build_step_name)
        setup_recipes
        @recipes.first.send build_step_name.to_s
      end

      # @api private
      # This method creates recipe instances for all required recipes from the given spec.
      def setup_recipes
        @recipes = []
        @recipes << DebHelperRecipe.new(spec)
        spec.recipes.reverse.each do |recipe|
          recipe.inner = @recipes.first
          @recipes.unshift recipe
        end
        @recipes.map(&:prepare)
      end
    end
  end
end
