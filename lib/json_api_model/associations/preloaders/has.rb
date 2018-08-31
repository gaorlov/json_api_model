module JsonApiModel
  module Associations
    module Preloaders
      class Has < Base
        def association_from( ids, associated_objects )
          associated_objects.select{ |r| ids.include? r.id }
        end
      end
    end
  end
end