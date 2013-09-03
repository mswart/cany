require 'cany/version'
require 'cany/specification'
require 'cany/recipe'
require 'cany/dpkg'
require 'cany/dpkg/creator'
require 'cany/dpkg/builder'
require 'cany/dpkg/deb_helper_recipe'

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
    spec = eval File::read(file), binding, file
    spec.base_dir = directory
    spec
  end
end
