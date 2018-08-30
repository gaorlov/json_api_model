module JsonApiModel
  module Associations
    module Preloaders
      class Base

        def initialize( association )
          @association = association
        end

        def preload( objects )
          queries = objects.map{ | object | association.query( object )}
        end
      end
    end
  end
end