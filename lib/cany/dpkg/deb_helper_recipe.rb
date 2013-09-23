module Cany
  module Dpkg
    class DebHelperRecipe < Cany::Recipe
      register_as :deb_helper

      def initialize(*args)
        super *args
        @log = File.read('debian/xikolo-account.debhelper.log') if File.exists?  'debian/xikolo-account.debhelper.log'
      end

      def create(creator)
        depend 'debhelper', version: '>= 7.0.50~', situation: :build
        depend '${shlibs:Depends}'
        depend '${misc:Depends}'
        depend creator.ruby_deb, situation: [:build, :runtime]
        depend creator.ruby_deb + '-dev', situation: :build
      end

      def clean
        exec %w(dh clean)
      end

      def build
        instance_eval &spec.build if spec.build
        exec %w(dh build)
      end

      def binary
        instance_eval &spec.binary if spec.binary
        File.write("debian/#{spec.name}.debhelper.log", @log)
        exec %w(dh binary)
      end
    end
  end
end
