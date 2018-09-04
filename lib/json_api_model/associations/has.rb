module JsonApiModel
  module Associations
    class Has < Base
      
      def action
        :where
      end

      def additional_options
        [ :as, :through ]
      end

      def key
        if json_relationship? || through?
          :id
        elsif as?
          "#{as}_id"
        else
          idify( base_class )
        end
      end

      def ids( instance )
        if json_relationship?
          instance.relationship_ids( name )
        elsif through?
          target_ids( instance )
        else
          instance.id
        end
      end

      def query( instance )
        { key => ids( instance ) }
      end

      protected

      def through
        opts[:through]
      end

      def through?
        opts.has_key? :through
      end

      def as
        opts[:as]
      end

      def as?
        opts.has_key? :as
      end

      def target_ids( instance )
        intermadiates = Array(instance.send( through ) )
        
        intermadiates.map do | intermediate | 
          intermediate.send( through_key )
        end
      end
      
      def through_key
        idify association_class
      end
    end
  end
end