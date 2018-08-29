module JsonApiModel
  module Associations
    class BelongsTo < Base
      include Flattable

      preloader = JsonApiModel::Associations::Preloaders::BelongsTo

      def action
        :find
      end

      def key
        "#{name}_id"
      end

      def query( instance )
        if instance.has_relationship_ids? name
          instance.relationship_ids( name ).first
        else
          instance.send key
        end
      end
    end
  end
end
