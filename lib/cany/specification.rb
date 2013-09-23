module Cany

  require 'cany/specification/dsl'

  class Specification
    EXT = 'canspec'

    attr_accessor :name, :description, :maintainer_name, :maintainer_email, :website, :licence, :version
    attr_accessor :base_dir, :recipes, :dependencies, :cany_version_constraint
    attr_accessor :build, :binary

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
  end
end
