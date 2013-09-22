require 'logger'

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

  # This methods creates a hash that returns an array as default value and also stores it
  # directly inside the hash, so that the return value can be changed without additional actions.
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
  require 'cany/dependency'
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
end
