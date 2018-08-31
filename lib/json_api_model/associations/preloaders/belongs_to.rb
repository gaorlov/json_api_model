module JsonApiModel
  module Associations
    module Preloaders
      class BelongsTo < Base
        def associated_key( object )
          object.id
        rescue => e
          nil
        end

        def lookup
          :id
        end
      end
    end
  end
end