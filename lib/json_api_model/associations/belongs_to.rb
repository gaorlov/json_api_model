module JsonApiModel
  module Associations
    class BelongsTo < Base
      include Flattable

      def action
        :find
      end

      def key
        "#{name}_id"
      end

      def query( instance )
        if instance.has_relationship_ids? name
          { id: instance.relationship_ids( name ) }
        else
          instance.send key
        end
      end

      def klass( instance )
        if polymorphic?
          class_name = instance.send "#{name}_class"
          class_name.constantize
        else
          super
        end
      end

      protected

      def additional_options
        [ :polymorphic ]
      end

      def polymorphic?
        opts[:polymorphic]
      end
    end
  end
end
