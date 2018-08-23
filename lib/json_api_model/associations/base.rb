module JsonApiModel
  module Associations
    class Base

      attr_accessor :name, :opts, :key

      def initialize( base_class, name, opts = {} )
        self.name = name
        self.opts = opts
        self.key  = idify( base_class )

        sanitize_opts( base_class )
      end

      def fetch( instance )
        process klass.send( action, query( instance ) )
      end

      protected

      def klass
        @klass ||= association_class( name, opts )
      end

      def association_class( name, opts = {} )
        a_class       = opts[:class]                   if opts.has_key? :class
        a_class_name  = opts[:class_name].constantize  if opts.has_key? :class_name

        a_class || a_class_name || derived_class_for( name )
      end

      def derived_class_for( name )
        name.to_s.singularize.classify.constantize
      end

      def idify( class_name )
        "#{class_name.to_s.demodulize.underscore}_id"
      end

      def supported_options
        [ :class, :class_name ] + additional_options
      end

      def additional_options
        []
      end

      def sanitize_opts( base_class )
        if name.to_s == "object"
          raise "#{base_class}: 'object_id' is a reserved keyword in ruby and cannot be overridden"
        end
        invalid_options = (opts.keys - supported_options)
        if invalid_options.present?
          list = invalid_options.map{|o|"'#{o}'"}.to_sentence
          plural = invalid_options.count > 1
          raise "#{base_class}: #{list} #{plural ? "are" : "is"} not supported."
        end
      end

      def process( results )
        results
      end
    end
  end
end
