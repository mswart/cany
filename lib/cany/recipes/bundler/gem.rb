class Cany::Recipes::Bundler::Gem
  # @api public
  # This methods returns the Gem instance for the specified gem
  # @param gem_name[Symbol] The gem name
  # @return Cany::recipes::Bundler::Gem
  def self.get(gem_name)
    @gems ||= {}
    @gems[gem_name] ||= new   gem_name
  end

  # @api public
  # Specify meta data about the given gem
  # @param gem_name[Symbol] the gem name
  # @block: A block that defines the meta data. Executed inside the DSL subclass
  def self.specify(gem_name, &block)
    DSL.new(get(gem_name)).run &block
  end

  # Clear all stored data. Only used in rspec
  def self.clear
    @gems = {}
  end

  attr_reader :name, :dependencies

  private
  def initialize(gem_name)
    @name = gem_name
    @dependencies = []
  end

  class DSL
    def initialize(gem)
      @gem = gem
    end

    def run(&block)
      instance_eval(&block)
    end

    # @api public
    # Adds a new dependency for the software. See Cany::Dependency for a more
    # abstract description about dependencies
    # See Cany::Mixins::DependMixin for parameter description
    include Cany::Mixins::DependMixin
    def depend(*args)
      @gem.dependencies << create_dep(*args)
    end
  end
end
