module Cany
  # Cany base error, design to catch all Cany errors at once
  class Error < StandardError
  end

  class MissingSpecification < Error
    def initialize(directory)
      super "No #{Specification::EXT} found in #{directory}"
    end
  end

  class MultipleSpecifications < Error
    def initialize(directory)
      super "Multiple #{Specification::EXT} found in #{directory}"
    end
  end

  class CommandExecutionFailed < Error
    def initialize(args)
      super "Could not execute: #{args.join(' ')}"
    end
  end

  class UnknownHook < Error
    def initialize(hook)
      super "Unknown hook \"#{hook}\""
    end
  end

  class UnknownOption < Error
    def initialize(option)
      super "Unknown option \"#{option}\""
    end
  end

  class UnloadedRecipe < Error
    def initialize(name)
      super "The recipe \"#{name}\" is not loaded by the specification."
    end
  end

  class UnknownRecipe < Error
    def initialize(name)
      super "The recipe \"#{name}\" is not registered!"
    end
  end

  class NoSystemRecipe < Error
    def initialize
      super "The specification has no loaded system recipe."
    end
  end

  # This exception is raised if the running Cany version satisfies not the
  # required Cany version constraint from the canspec.
  class UnsupportedVersion < Error
    def initialize(required_version)
      super "The package specification requires Cany in version" \
        " \"#{required_version}\" but Cany has version \"#{Cany::VERSION}\""
    end
  end
end
