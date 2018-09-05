module JsonApiModel
  module Associations
    class Preloader

      class << self
        def preload( objects, *preloads )
          new( objects, preloads ).preload
        end
      end

      attr_accessor :objects, :preloads

      def initialize( objects, preloads )
        @objects  = Array( objects ).compact
        @preloads = preloads

        validate_homogenity!
      end

      def preload
        @preloads.each do | preload |
          case preload
          when Hash
            preload.each do | preload, subpreloads |
              preloader = Preloaders.preloader_for( @objects, preload )

              subobjects = preloader.load
              preloader.assign subobjects

              subobjects.preload( subpreloads )
            end
          else
            Preloaders.preloader_for( @objects, preload ).fetch
          end
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