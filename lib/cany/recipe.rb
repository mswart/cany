module Cany
  class Recipe

    # @api public
    # This method should be call in subclasses to register new recipe instances. Cany ignores any
    # recipe subclasses which does not call register_as. If multiple recipes register on the same
    # name the later one will overwrite the earlier one and therefore used by Cany.
    # @param [Symbol] name A ruby symbol as name for the recipe. It should be short and recognizable
    def self.register_as(name)
      @@recipes ||= {}
      @@recipes[name] = self
    end

    # @api public
    # Looks for the class registered for the given name
    # @param [Symbol] name the name the class is search for
    # @return [Cany::Recipe, nil] Returns the found class or nil if no class is registered on this
    #  name
    def self.from_name(name)
      @@recipes[name]
    end

    # Creates a new instance of this recipe
    # @param [Cany::Specification] spec Specification object
    # @param [Cany::Recipe, nil] inner Inner recipes should should be call between the pre and post
    #  actions of this class. Nil means most inner recipes.
    def initialize(spec, inner)
      @spec = spec
      @inner = inner
    end

    attr_reader :spec, :inner

    # @api public
    # Run a command inside the build directory
    def exec(*args)
      system *args.flatten
    end
  end
end
