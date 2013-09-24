require 'logger'

module Cany
  # @raise [MissingSpecification] if no canspec is found in the directory
  # @raise [MultipleSpecifications] if multiple canspec files are found inside
  #   the directory
  def self.setup(directory='.')
    specs = Dir[directory + '/*.' + Specification::EXT]
    raise MissingSpecification.new(directory) if specs.size == 0
    raise MultipleSpecifications.new(directory) if specs.size > 1
    file = specs.first
    spec = eval File::read(file), binding, file
    spec.base_dir = directory
    spec
  end

  # This methods creates a hash that returns an array as default value and also
  # stores it directly inside the hash, so that the return value can be changed
  # without additional actions.
  # @example
  #   hash = hash_with_array_as_default
  #   hash[:hans] << 'otto'
  #   hash[:hash] == ['otto']
  def self.hash_with_array_as_default
    {}.tap do |hash|
      hash.default_proc = Proc.new do |_, key|
        hash[key] = []
      end
    end
  end

  # @api public
  # @return [Logger]
  def self.logger
    @logger ||= create_logger
  end

  def self.create_logger
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    org_formatter = Logger::Formatter.new
    logger.formatter = proc do |severity, datetime, progname, msg|
      if severity == "INFO"
        "   #{msg}\n"
      else
        org_formatter.call severity, datetime, progname, msg
      end
    end
    logger
  end

  require 'cany/version'
  require 'cany/errors'
  # This module contains ruby mixins that are used within multiple classes to share code.
  module Mixins
    require 'cany/mixins/depend_mixin'
  end
  require 'cany/dependency'
  require 'cany/specification'
  require 'cany/recipe'


  # Applications using common libraries to concentrate on things that are new
  # and no solved by existing software. Therefore there are similar deploy
  # tasks that are needed for applications.
  #
  # Cany groups common deploy aspects in recipes. This recipes can be included
  # and used by the application. Normally there exists one recipe for every
  # important software that is used by the application and influences directly
  # the way the applications needs to be installed.
  #
  # Central recipes are bundler as gem package manager and rails as popular
  # web framework.
  #
  # To support starting the applications there is also a collection of recipes
  # deploying ruby web server or background services.
  module Recipes
    require 'cany/recipes/bundler'
    require 'cany/recipes/bundler/gem'
    require 'cany/recipes/bundler/gem_db'
    require 'cany/recipes/rails'
    require 'cany/recipes/web_server'
    require 'cany/recipes/thin'
    require 'cany/recipes/unicorn'
    require 'cany/recipes/sidekiq'
  end


  # Cany is designed to be able to pack applications for multiple package
  # managers. Although there is currently only support for debian/ubuntu.
  # All DPKG specific things are group into the Dpkg namespace.
  module Dpkg
    require 'cany/dpkg'
    require 'cany/dpkg/creator'
    require 'cany/dpkg/builder'
    require 'cany/dpkg/deb_helper_recipe'
  end
end
