module JsonApiModel
  module Associations
    autoload :Base,       'json_api_model/associations/base'
    autoload :BelongsTo,  'json_api_model/associations/belongs_to'
    autoload :Flattable,  'json_api_model/associations/flattable'
    autoload :Has,        'json_api_model/associations/has'
    autoload :HasMany,    'json_api_model/associations/has_many'
    autoload :HasOne,     'json_api_model/associations/has_one'
    autoload :Preloader,  'json_api_model/associations/preloader'
    autoload :Preloaders, 'json_api_model/associations/preloaders'
  end
end