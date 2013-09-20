module Cany
  class Specification
    class DSL
      def initialize(specification)
        @specification = specification
      end

      def exec(&block)
        instance_eval(&block)
      end

      def self.delegate(*methods)
        methods.each do |method|
          module_eval(<<-EOS, __FILE__, __LINE__)
            def #{method}(*args, &block)
              @specification.send :'#{method}=', *args, &block
            end
            EOS
        end
      end

      delegate :name, :description, :maintainer_name, :maintainer_email, :website, :licence, :version

      # This include the given recipe into the build process.
      # @param [Symbol] name The name of the recipe as symbol.
      def use(name, &block)
        @specification.recipes << Cany::Recipe.from_name(name).new(@specification, &block)
      end

      def build(&block)
        @specification.build = block
      end

      def binary(&block)
        @specification.binary = block
      end
    end
  end
end
