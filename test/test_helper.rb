$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "json_api_client"

require 'webmock/minitest'

require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
end

require "json_api_model"
require "minitest/autorun"

module Example
  module Client
    class Base < JsonApiClient::Resource
      self.site = "http://example.com"
    end

    class User < Base
      custom_endpoint :search, on: :collection, request_method: :get
      
      class << self
        def base_class_method
          :something
        end

        def lucky_search( params = {} )
          search( params ).first
        end
      end
    end
  end


  class User < JsonApiModel::Model
    wraps Example::Client::User

    def instance_method
      42
    end

    def self.class_method
      :also_42
    end
  end
end


class DummyInstrumenter
  attr_accessor :last_event

  def instrument( name, payload = {} )
    @last_event = { name: name,
                    payload: payload }

    yield payload
  end
end

JsonApiModel.instrumenter = DummyInstrumenter.new