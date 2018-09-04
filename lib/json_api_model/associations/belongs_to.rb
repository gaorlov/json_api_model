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

      def ids( instance )
        if json_relationship?
          instance.relationship_ids( name ).first
        else
          instance.send key
        end
      end

      def query( instance )
        ids( instance )
      end
    end
  end
end
