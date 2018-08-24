require "json_api_model/version"

module JsonApiModel

  autoload :Associations, 'json_api_model/associations'
  autoload :Associatable, 'json_api_model/associatable'
  autoload :Model,        'json_api_model/model'
  autoload :Instrumenter, 'json_api_model/instrumenter'
  autoload :ResultSet,    'json_api_model/result_set'
  autoload :Scope,        'json_api_model/scope'

  class << self
    attr_accessor :instrumenter
  end

  self.instrumenter = Instrumenter::NullInstrumenter.new
end
