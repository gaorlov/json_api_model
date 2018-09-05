module JsonApiModel
  module Associations
    module Preloaders
      class Base

        attr_accessor :association
        delegate :key, :name, :association_class, :action, :process, :ids, :base_class, to: :association

        def initialize( objects, association )
          @objects     = Array( objects )
          @association = association
        end

        def fetch
          assign load
        end

        def load
          association_class.send( action, query( @objects ) ).to_a
        end

        def assign( results )
          validate_assignability!( results )
          @objects.each do | object |

            associated_objects = results.select do |r|
              associated_key( r ).in? Array( ids( object ) )
            end

            object.send( "#{name}=", process( associated_objects ) )
          end
        end

        protected

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