module Cany
  module Dpkg
    class DebHelperRecipe < Cany::Recipe
      register_as :deb_helper

      def initialize(*args)
        super *args
        @log = File.read('debian/xikolo-account.debhelper.log') if File.exists?  'debian/xikolo-account.debhelper.log'
        exec 'dh_prep'
      end

      def clean
        exec %w(dh clean)
      end

      def build
        exec %w(dh build)
      end

      def binary
        File.write('debian/xikolo-account.debhelper.log', @log)
        exec %w(dh binary)
      end
    end
  end
end
