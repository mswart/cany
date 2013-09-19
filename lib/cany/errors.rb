module Cany
  # Cany base error, design to catch all cany errors at once
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
end
