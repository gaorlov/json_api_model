module JsonApiModel
  module Associations
    module Preloaders
      autoload :Base,       'json_api_model/associations/preloaders/base'
      autoload :BelongsTo,  'json_api_model/associations/preloaders/belongs_to'
      autoload :HasMany,    'json_api_model/associations/preloaders/has_many'
      autoload :HasOne,     'json_api_model/associations/preloaders/has_one'
    end
  end
end