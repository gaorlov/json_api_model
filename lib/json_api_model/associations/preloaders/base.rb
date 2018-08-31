module JsonApiModel
  module Associations
    module Preloaders
      class Base

        attr_accessor :association
        delegate :key, :relationship_key, :association_class, :process, :ids, to: :association

        def initialize( objects, association )
          @objects     = objects
          @association = association
        end

        def fetch
          assign @association.fetch( @objects )
        end

        private

        def assign( associated_objects )
          validate_assignability!
          @objects.each do | object |

            association = association_from( ids( object ), associated_objects )

            if association
              object.__cached_associations[name] = process association
            end
          end
        end

        def validate_assignability!( associated_objects )
          associated_objects.each do |obj|
            unless assignable?( object )
              raise "Preloading #{association_class}.#{name} failed: results don't identify an association."
            end
          end
        end

        def assignable?( object )
          obj.respond_to?( key ) || obj.has_relationship_ids( relationship_key )
        rescue
          false
        end
      end
    end
  end
end