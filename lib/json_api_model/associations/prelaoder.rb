module JsonApiModel
  module Associations
    class Preloader

      class << self
        def preload( objects, *preloads )
          new( object, preloads ).preload!
        end
      end

      def initialize( objects, preloads )
        @objects  = Array( objects ).compact
        @preloads = preloads

        validate_homogenity!
      end

      def preload!
        return @objects if noop?

        @preloads.each do | preload |
          association_for( preload ).preload( @objects )
        end
      end

      private

      def noop?
        @objects.empty? || @assiciations.empty?
      end

      def association_for( preload )
        object_class._associations.fetch preload
      rescue KeyError
        raise "#{object_class}##{preload.to_s} is not a valid association"
      end

      def object_class
        @object_class ||= @objects.first.class
      end

      def validate_homogenity!
        unless homogeneous?
          raise "JsonApiModel::Associations::Preloader.preload called with a heterogeneous array of objects."
        end
      end
        
      def homogeneous?
        @objects.all do |obj|
          obj.is_a?(object_class)
        end
      end
    end
  end
end