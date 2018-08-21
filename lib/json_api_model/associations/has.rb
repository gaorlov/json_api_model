module JsonApiModel
  module Associations
    class Has < Base
      
      def query( instance )
        if instance.has_relationship_ids? name
          { id: relationship_ids( instance ) }
        elsif through?
          { id: target_ids( instance ) }
        elsif as?
          { "#{as}_id" => instance.id }
        else
          { key => instance.id }
        end
      end

      def additional_options
        [ :as, :through ]
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
        idify klass
      end
    end
  end
end