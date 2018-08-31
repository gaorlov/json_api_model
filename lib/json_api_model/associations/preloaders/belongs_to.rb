module JsonApiModel
  module Associations
    module Preloaders
      class BelongsTo < Base
        def association_from( id, associated_objects )
          associated_objects.select{ |r| ids( r ) == id }
        end
      end
    end
  end
end