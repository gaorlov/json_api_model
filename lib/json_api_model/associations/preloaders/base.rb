module JsonApiModel
  module Associations
    module Preloaders
      class Base

        attr_accessor :association
        delegate :key, :name, :relationship_key, :association_class, :process, :ids, :unprocessed_fetch, to: :association

        def initialize( objects, association )
          @objects     = Array( objects )
          @association = association
        end

        def fetch
          assign [ unprocessed_fetch( @objects ) ].flatten
        end

        protected

        def assign( results )
          validate_assignability!( results )
          @objects.each do | object |

            associated_objects = results.select do |r|
              associated_key( r ).in? Array( ids( object ) )
            end

            object.__cached_associations ||= {}
            object.__cached_associations[name] = process associated_objects
          end
        end

        def validate_assignability!( results )
          results.each do | object |
            unless associated_key( object )
              raise "Preloading #{association_class}.#{lookup} failed: results don't identify an association."
            end
          end
        end
      end
    end
  end
end