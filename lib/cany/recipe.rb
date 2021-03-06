require 'fileutils'

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
      module_eval(<<-EOS, __FILE__, __LINE__)
        def name
          :#{name}
        end
        EOS
    end

    # @api public
    # Looks for the class registered for the given name
    # @param [Symbol] name the name the class is search for
    # @return [Cany::Recipe] Returns the found class or nil
    # @raise UnknownRecipe if there is no recipe registered for this name.
    def self.from_name(name)
      raise UnknownRecipe.new(name) unless @@recipes[name]
      @@recipes[name]
    end

    # Creates a new instance of this recipe
    # @param [Cany::Specification] spec Specification object
    def initialize(spec, &configure_block)
      @spec = spec
      @inner = nil
      @hooks = Hash[(self.class.defined_hooks || []).map do |name|
        [name, Cany.hash_with_array_as_default]
      end]
      @options = Hash[(self.class.defined_options || {}).map do |name, default|
        [name, default.dup]
      end]
      self.class.const_get(:DSL).new(self).exec(&configure_block) if configure_block
    end

    # Specify the inner recipe for the current one.
    # @param [Cany::Recipe, nil] inner Inner recipes should should be call between the pre and post
    #  actions of this class. Nil means most inner recipes.
    def inner=(inner)
      @inner = inner
    end

    attr_reader :spec, :inner

    # API to use inside the recipe
    ##############################

    # @api public
    # Run a command inside the build directory. In most cases it is not needed to call this method
    # directly. Look at the other helper methods.
    #
    # The method expects as arguments the program name and additional parameters for the program.
    # The arguments can be group with arguments, but must not:
    # @example
    #   exec 'echo', %w(a b)
    #   exec ['echo', 'a', 'b']
    #   exec 'echo', 'a', 'b'
    # @raise [CommandExecutionFailed] if the executed program exists with a
    #   non-zero exit code.
    def exec(*args)
      args.flatten!
      Cany.logger.info args.join(' ')
      unless system(*args)
        raise CommandExecutionFailed.new args
      end
    end
    # exec is special name in same situations it may no work but this alias should work always
    alias :exec_ :exec

    # @api public
    # Run a ruby task (like gem, bundle, rake ...)
    #
    # The method expects as arguments the program name and additional parameters for the program.
    # See exec for more examples
    def ruby_bin(*args)
      exec RbConfig.ruby, '-S', *args
    end

    # @api public
    # Install files or directory from the build directory
    # @param source[String] The relative file name to a filename or directory inside the build
    #   directory that should be installed/copied into the destination package
    # @param destination[String] The diretory name into that the file or directory should be
    #   installed
    def install(source, destination)
      exec 'dh_install', source, destination
    end

    # @api public
    # Install a file. The content is passed as argument. This method is designed to be used by
    # recipes to create files dynamically.
    # @param [String] filename The absolute file name for the file inside the package.
    # @param [String] content The file content
    def install_content(filename, content)
      FileUtils.mkdir_p File.dirname File.join('debian', spec.name, filename)
      File.open File.join('debian', spec.name, filename), 'w' do |f|
        f.write content
      end
    end

    # @api public
    # Installs/creates an empty directory
    # @param [String] path The path name
    def install_dir(path)
      exec 'dh_installdirs', path
    end

    # @api public
    # Create a file named destination as a link to a file named source
    def install_link(source, destination)
      exec 'dh_link', source, destination
    end

    # @api public
    # Specify a command call (program + args) that should be installed as service and started
    # automatically.
    # This method should be only call inside the binary step.
    # @param name[Symbol] A short identifier. Used to separate different services. E.g. the name
    #   of the web server that is launched by this command (like puma, unicorn, thin)
    # @param command[Array<String>] The command that should be started and its parameter. The first
    #   element is the command name - can be absolute or relative path name (than searched in path)
    # @param opts[Hash] Service behavior options
    # @option opts[String] :user As which user should the command executed (default is root)
    # @option opts[String] :group As which group should the command executed (default is root)
    def install_service(*args)
      recipe(:system).install_service(*args)
    end

    # @api public
    # Ensure that the given files or directories are no present. Directories are removed
    # recursively.
    def rmtree(*args)
      args.flatten.each do |path|
        ::FileUtils.remove_entry path if File.exists? path
      end
    end

    class << self
      attr_accessor :defined_hooks, :defined_options

      # @api public
      # Define a new hook
      # @param name[Symbol]
      def hook(name)
        @defined_hooks ||= []
        @defined_hooks  << name
      end

      # @api public
      # Define a configure option. These kind of option are design for other
      # recipes not for the user. See Recipe::DSL for this.
      # @param name[Symbol] The name of the option. The option name is scoped
      #    inside a recipe.
      def option(name, default={})
        @defined_options ||= {}
        @defined_options[name] = default
      end
    end

    def hook(name)
      @hooks[name].tap do |hook|
        raise UnknownHook.new name unless hook
      end
    end

    # @api public
    # Ask for the current values for a defined option
    def option(name)
      @options[name].tap do |option|
        raise UnknownOption.new name unless option
      end
    end

    # @api public
    # Configure an other recipe
    # @param name[Symbol] The option name
    # @param options[Hash] The configuration data itself.
    def configure(name, options)
      option(name).merge! options
    end

    # @api public
    # Run defined actions for a hook
    # @param name[Symbol] hook identification, no error is raised on unknown hooks
    # @param state[Symbol] state that should be executed (:before, :after or :around)
    def run_hook(name, state)
      hook(name)[state].each do |block|
        Cany.logger.info  "run #{block} for hook #{name} in state #{state} ..."
        instance_eval(&block)
      end
    end

    # @api public
    # Access the recipe instance from another loaded recipe of this
    # specification
    # @param name[Symbol] recipe name
    def recipe(name)
      return spec.system_recipe if name == :system
      recipe_class = Recipe.from_name(name)
      @spec.recipes.each do |one_recipe|
        return one_recipe if one_recipe.instance_of? recipe_class
      end
      raise UnloadedRecipe.new name
    end

    # @api public
    # Adds a new dependency for the software. See Cany::Dependency for a more
    # abstract description about dependencies
    # See Cany::Mixins::DependMixin for parameter description
    include Cany::Mixins::DependMixin
    def depend(*args)
      @spec.dependencies << create_dep(*args)
    end

    # default implementation:
    #########################

    # @!group Recipe Steps - to be overridden in subclass

    # @api public
    # Prepares the recipes to run things. This is call exactly once for all recipes before
    # recipes actions are executed.
    def prepare
    end

    # @api public
    # This step is executed to create the distribution specific packages from canspec. The recipe
    # can e.g. add additional dependencies or adjust the package meta data.
    def create(creator)
    end

    # @api public
    # clean the build directory from all temporary and created files
    def clean
      inner.clean
    end

    # @api public
    # build the program (means ./configure and make)
    def build
      inner.build
    end

    # @api public
    # create binary (package) version of this file (means make install)
    def binary
      inner.binary
    end

    # @!endgroup


    # This superclass helps recipes to create easily an own mini DSL to let the user configure the
    # recipe with it.
    class DSL
      def initialize(recipe)
        @recipe = recipe
      end

      # Evaluate a given block inside the dsl.
      def exec(&block)
        instance_eval(&block)
      end

      # This is a simple delegate helper. It can be used to pass option directly to recipe instance.
      # @param [Symbol] param1 Multiple symbol names
      def self.delegate(*methods)
        methods.each do |method|
          module_eval(<<-EOS, __FILE__, __LINE__)
          def #{method}(*args, &block)
            @recipe.send :'#{method}=', *args, &block
          end
          EOS
        end
      end

      def before(hook_name, &block)
        @recipe.hook(hook_name)[:before] << block
      end

      def after(hook_name, &block)
        @recipe.hook(hook_name)[:after] << block
      end

      def around(hook_name, &block)
        @recipe.hook(hook_name)[:around] << block
      end
    end
  end
end
