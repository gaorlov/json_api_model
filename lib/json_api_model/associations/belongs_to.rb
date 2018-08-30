module JsonApiModel
  module Associations
    class BelongsTo < Base
      include Flattable

      preloader_class = JsonApiModel::Associations::Preloaders::Base

      def action
        :find
      end

      def key
        "#{name}_id"
      end

      private

      def single_query( instance )
        if instance.has_relationship_ids? name
          instance.relationship_ids( name ).first
        else
          instance.send key
        end
      end

      def bulk_query( instances )

      end
    end
  end
end
