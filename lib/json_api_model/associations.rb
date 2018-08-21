module JsonApiModel
  module Associations
    autoload :Base,       'json_api_model/associations/base'
    autoload :BelongsTo,  'json_api_model/associations/belongs_to'
    autoload :Has,        'json_api_model/associations/has'
    autoload :HasMany,    'json_api_model/associations/has_many'
    autoload :HasOne,     'json_api_model/associations/has_one'
  end
end