require 'cany/version'
require 'cany/errors'
require 'cany/specification'
require 'cany/recipe'
require 'cany/recipes/bundler'
require 'cany/recipes/rails'
require 'cany/recipes/web_server'
require 'cany/recipes/thin'
require 'cany/dpkg'
require 'cany/dpkg/creator'
require 'cany/dpkg/builder'
require 'cany/dpkg/deb_helper_recipe'

module Cany
  def self.setup(directory='.')
    specs = Dir[directory + '/*.' + Specification::EXT]
    raise MissingSpecification.new(directory) if specs.size == 0
    raise MultipleSpecifications.new(directory) if specs.size > 1
    file = specs.first
    spec = eval File::read(file), binding, file
    spec.base_dir = directory
    spec
  end
end
