module Cany

  require 'cany/specification/dsl'

  class Specification
    attr_accessor :name

    def initialize(dsl=Cany::Specification::DSL, &block)
      dsl.new(self).exec(&block)
    end
  end
end
