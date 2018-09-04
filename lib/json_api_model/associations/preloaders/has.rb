module JsonApiModel
  module Associations
    module Preloaders
      class Has < Base
        def associated_key( object )
          object.respond_to?( key ) ? object.send( key ) : object.id
        rescue => e
          nil
        end

        def query( instances )
          instances.each_with_object( { key => [] } ) do | instance, query |
            query[ key ] += Array( ids( instance ) )
            query[ key ].uniq!
          end
        end

        protected

        def lookup
          base_class.to_s.demodulize.underscore
        end
      end
    end
  end
end