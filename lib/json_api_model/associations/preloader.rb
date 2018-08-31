module JsonApiModel
  module Associations
    class Preloader

      class << self
        def preload( objects, *preloads )
          new( objects, preloads ).preload
        end
      end

      def initialize( objects, preloads )
        @objects  = Array( objects ).compact
        @preloads = preloads

        validate_homogenity!
      end

      def preload
        @preloads.each do | preload |
          preloader = Preloaders.preloader_for( @objects, preload )
          preloader.fetch
        end

        @objects
      end

      private

      def validate_homogenity!
        unless homogeneous?
          raise "JsonApiModel::Associations::Preloader.preload called with a heterogeneous array of objects."
        end
      end

      def object_class
        @object_class ||= @objects.first.class
      end

      def homogeneous?
        @objects.all? do |obj|
          obj.is_a?(object_class)
        end
      end
    end
  end
end