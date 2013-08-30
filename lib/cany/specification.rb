module Cany

  require 'cany/specification/dsl'

  class Specification
    EXT = 'canspec'

    attr_accessor :name, :description, :maintainer_name, :maintainer_email, :website, :licence
    attr_accessor :base_dir

    def initialize(dsl=Cany::Specification::DSL, &block)
      dsl.new(self).exec(&block)
    end
  end
end
