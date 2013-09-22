module Cany

  require 'cany/specification/dsl'

  class Specification
    EXT = 'canspec'

    attr_accessor :name, :description, :maintainer_name, :maintainer_email, :website, :licence, :version
    attr_accessor :base_dir, :recipes, :dependencies
    attr_accessor :build, :binary

    def initialize(dsl=Cany::Specification::DSL, &block)
      @recipes = []
      @dependencies = []
      setup dsl, &block
    end

    def setup(dsl=Cany::Specification::DSL, &block)
      dsl.new(self).exec(&block)
    end
  end
end
