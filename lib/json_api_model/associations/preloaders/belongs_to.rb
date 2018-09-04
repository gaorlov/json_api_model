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

        def query( instances )
          instances.map do | instance |
            ids( instance )
          end.uniq
        end
      end
    end
  end
end