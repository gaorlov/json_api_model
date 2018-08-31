module JsonApiModel
  module Associations
    module Preloaders
      class Has < Base
        def associated_key( object )
          object.respond_to?( association_key ) ? object.send( association_key ) : object.id
        rescue => e
          nil
        end

        protected

        def lookup
          relationship_key
        end

        private

        def association_key
          key( @objects.first )
        end
      end
    end
  end
end