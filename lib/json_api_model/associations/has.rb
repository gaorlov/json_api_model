module JsonApiModel
  module Associations
    class Has < Base
      
      def action
        :where
      end

      def query( instance )
        if instance.has_relationship_ids? name
          { id: instance.relationship_ids( name ) }
        elsif through?
          { id: target_ids( instance ) }
        else
          { key => instance.id }
        end
      end

      def additional_options
        [ :through ]
      end

      protected

      def through
        opts[:through]
      end

      def through?
        opts.has_key? :through
      end

      def target_ids( instance )
        intermadiates = Array(instance.send( through ) )
        
        intermadiates.map do | intermediate | 
          intermediate.send( through_key )
        end
      end
      
      def through_key
        idify klass
      end
    end
  end
end