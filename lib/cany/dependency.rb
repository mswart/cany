module Cany
  # This class representing a dependency on an abstract object like a gem or a external software.
  #
  # Depending on the platform different packages are needed to satisfy the dependency. This class
  # stores which packages (and optional a version constraint) is needed for every platform,
  # distribution or distribution release.
  #
  # This class differs between two different situation where dependencies are needed: to build
  # the package (:build) or to run/use the packages (:runtime).
  #
  # A dependency has also a priority:
  #   - :required: The dependency have to be fulfilled in every situation otherwise it is not
  #     possible to build or run the application.
  # Other priorities are planed but currently not implemented.
  class Dependency
    # Define the default package name and an optional version constraint for all
    # @param name[String] A package name
    # @param version[String, nil] A version constraint
    def define_default(name, version=nil)
      default << [name, version]
    end

    # Define the default package name and an optional version constraint for a distribution
    # @param distro[Symbol] The distribution name like :ubuntu, :debian ...
    # @param name[String] A package name
    # @param version[String, nil] A version constraint
    def define_on_distro(distro, name, version=nil)
      distros[distro] << [name, version]
    end

    # Define the package name and an optional version constraint for a distribution release
    # @param distro[Symbol] The distribution name like :ubuntu, :debian ...
    # @param release[Symbol] The distribution release like :precise for ubuntu 12.04
    # @param name[String] A package name
    # @param version[String, nil] A version constraint
    def define_on_distro_release(distro, release, name, version=nil)
      distro_releases[[distro, release]] << [name, version]
    end

    # Evaluation which packages (with version constraint) are needed for the given distrobution
    # release.
    # @param distro[Symbol] The distribution name like :ubuntu, :debian ...
    # @param release[Symbol] The distribution release like :precise for ubuntu 12.04
    # @return [Array<String, String>]
    def determine(distro, release)
      return distro_releases[[distro, release]] if distro_releases.has_key? [distro, release]
      return distros[distro] if distros.has_key? distro
      default
    end

    protected

    def default
      @default ||= []
    end

    def distros
      @distros ||= hash_with_array_as_default
    end

    def distro_releases
      @distro_releases ||= hash_with_array_as_default
    end

    # This methods creates a hash that returns an array as default value and also stores it
    # directly inside the hash, so that the return value can be changed without additional actions.
    # @example
    #   hash = hash_with_array_as_default
    #   hash[:hans] << 'otto'
    #   hash[:hash] == ['otto']
    def hash_with_array_as_default
      {}.tap do |hash|
        hash.default_proc = Proc.new do |_, key|
          hash[key] = []
        end
      end
    end
  end
end
