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
    def initialize
      @default = []
      @distros = Cany.hash_with_array_as_default
      @distro_releases ||= Cany.hash_with_array_as_default
      @situations = [:runtime]
    end

    attr_reader :situations
    def situations=(value)
      @situations = value.kind_of?(Array) ? value : [value]
    end
    def runtime?; @situations.include? :runtime; end
    def build?; @situations.include? :build; end

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

    attr_reader :default, :distros, :distro_releases
  end
end
