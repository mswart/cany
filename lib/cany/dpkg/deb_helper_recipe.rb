module Cany
  module Dpkg
    class DebHelperRecipe < Cany::Recipe
      register_as :deb_helper

      def clean
        exec %w(dh clean)
      end

      def build
        exec %w(dh build)
      end

      def binary
        exec %w(dh binary)
      end
    end
  end
end
