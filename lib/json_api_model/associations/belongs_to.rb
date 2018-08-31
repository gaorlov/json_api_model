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
        if json_relationship?( instance )
          instance.relationship_ids( name ).first
        else
          instance.send key
        end
      end

      private

      def single_query( instance )
        ids( instance )
      end

      def bulk_query( instances )
        instances.map do | instance |
          single_query( instance )
        end.uniq
      end
    end
  end
end
