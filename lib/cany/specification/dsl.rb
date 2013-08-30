module Cany
  class Specification
    class DSL
      def initialize(specification)
        @specification = specification
      end

      def exec(&block)
        instance_eval &block
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

      delegate :name, :description, :maintainer_name, :maintainer_email, :website, :licence
    end
  end
end
