$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "json_api_client"

require 'webmock/minitest'

require 'simplecov'
SimpleCov.start

require "json_api_model"
require "minitest/autorun"

module Example
  module Client
    class Base < JsonApiClient::Resource
      self.site = "http://example.com"
    end

    class User < Base
    end

    class Profile < Base
    end

    class Option < Base
    end

    class Org < Base
    end
  end


  class User < JsonApiModel::Model
    wraps Example::Client::User

    belongs_to :org
    has_one :profile
    has_many :options

    has_many :properties

    def instance_method
      42
    end
  end


end

class FakeActiveRecord::Base
  def where( args = {} )
  end

  def find( id )
  end
end

class LocalUserOwner < FakeActiveRecord::Base

end

class LocalUserProperties < FakeActiveRecord::Base

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