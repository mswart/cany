module Cany

  require 'cany/specification/dsl'

  class Specification
    EXT = 'canspec'

    attr_accessor :name, :description, :maintainer_name, :maintainer_email, :website, :licence, :version
    attr_accessor :base_dir, :recipes, :dependencies, :cany_version_constraint
    attr_accessor :prepare, :clean, :build, :binary

    def initialize(dsl=Cany::Specification::DSL, &block)
      @recipes = []
      @dependencies = []
      setup dsl, &block
    end

    def setup(dsl=Cany::Specification::DSL, &block)
      dsl.new(self).exec(&block)
    end

    # @api public
    # Return all dependencies needed to build this package
    # @return [Array<Dependency>] A list of dependencies.
    def build_dependencies
      dependencies.select(&:build?)
    end

    # @api public
    # Return all dependencies needed to build this package
    # @return [Array<Dependency>] A list of dependencies.
    def runtime_dependencies
      dependencies.select(&:runtime?)
    end

    # Define the given recipe instance as system recipe. It can be accessed by other recipes under
    # the system name and it is added as last recipe and do system specific things.
    # At the moment the only recipe designed to work as system recipe is the DebHelperRecipe
    # The attribute should be set after all recipe changes are over.
    # @param recipe[Recipe] the system recipe instance
    def system_recipe=(recipe)
      @system_recipe = recipe
      @recipes << recipe
    end
    # Return the system recipe for this specification.
    # @return [Recipe] The system reciep
    # @raise [NoSystemRecipe] if no system recipe was specified.
    def system_recipe
      raise NoSystemRecipe.new unless @system_recipe
      @system_recipe
    end

    # @api private
    # This method creates recipe instances for all required recipes from the given spec.
    def setup_recipes
      last_recipe = nil
      recipes.reverse.each do |recipe|
        recipe.inner = last_recipe unless last_recipe.nil?
        last_recipe = recipe
      end
      recipes.map(&:prepare)
    end

    def to_s
      "Cany::Specification<#{object_id}>(name=#{name}, recipes=[#{recipes.map(&:name).join(', ')}]"
    end
    alias_method :inspect, :to_s
  end
end
