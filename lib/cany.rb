require 'cany/version'
require 'cany/specification'

module Cany
  class MissingSpecification < Exception
  end

  class MultipleSpecifications < Exception
  end

  def self.setup(directory='.')
    specs = Dir[directory + '/*.' + Specification::EXT]
    raise MissingSpecification, "No #{Specification::EXT} found in #{directory}" if specs.size == 0
    raise MultipleSpecifications, "Multiple #{Specification::EXT} found in #{directory}" if specs.size > 1
    file = specs.first
    eval File::read(file), binding, file
  end
end
