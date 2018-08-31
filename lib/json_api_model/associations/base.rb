module JsonApiModel
  module Associations
    class Base

      attr_accessor :name, :opts, :key, :base_class
      delegate :preload, to: :preloader

      def initialize( base_class, name, opts = {} )
        self.name       = name
        self.opts       = opts
        self.key        = idify( base_class )
        self.base_class = base_class

        validate_opts!
      end

      def fetch( instance )
        process association_class.send( action, query( instance ) )
      end

      def json_relationship?( instance )
        instance.has_relationship_ids?( name )
      end

      def relationship_key
         association_class.to_s.demodulize.underscore
      end

      protected

      def idify( class_name )
        "#{class_name.to_s.demodulize.underscore}_id"
      end

      def query( instance )
        case instance
        when Array
          bulk_query instance
        else
          single_query instance
        end
      end

      def association_class
        opts[:class] ||
        opts[:class_name]&.constantize ||
        derived_class
      end

      def derived_class
        name.to_s.singularize.classify.constantize
      end

      def supported_options
        [ :class, :class_name ] + additional_options
      end

      def additional_options
        []
      end

      def validate_opts!
        if name.to_s == "object"
          raise "#{base_class}: 'object_id' is a reserved keyword in ruby and cannot be overridden"
        end
        (opts.keys - supported_options).each do | opt |
          raise "#{base_class}: #{opt} is not supported."
        end
      end

      def process( results )
        results
      end
    end
  end
end
