module JsonApiModel
  module Associations
    module Preloaders
      autoload :Base,       'json_api_model/associations/preloaders/base'
      autoload :BelongsTo,  'json_api_model/associations/preloaders/belongs_to'
      autoload :Has,        'json_api_model/associations/preloaders/has'

      class << self
        def preloader_for( objects, preload )
          klass = object_class( objects )
          association = klass.__associations.fetch preload

          PREOLOADERS[ association.class ].new( objects, association )
        rescue KeyError
          raise "#{klass}##{preload.to_s} is not a valid association"
        end

        private 

        def object_class( objects )
          objects.first.class
        end
      end

      PREOLOADERS = {
                      JsonApiModel::Associations::BelongsTo => JsonApiModel::Associations::Preloaders::BelongsTo,
                      JsonApiModel::Associations::HasOne    => JsonApiModel::Associations::Preloaders::Has,
                      JsonApiModel::Associations::HasMany   => JsonApiModel::Associations::Preloaders::Has
                    }
    end
  end
end