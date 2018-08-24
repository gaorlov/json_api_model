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
    end
  end
end
