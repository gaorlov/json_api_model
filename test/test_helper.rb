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

    class Blank < Base
    end

    class Profile < Base
    end

    class Option < Base
    end

    class Org < Base
    end
  end

  class Profile < JsonApiModel::Model
    wraps Example::Client::Profile
  end

  class User < JsonApiModel::Model
    wraps Example::Client::User

    belongs_to :org, class_name: "Example::Org"
    has_one :blank
    has_one :profile, class: Example::Profile
    has_many :options, class_name: "Example::Option"

    belongs_to :something
    has_one :whatever
    has_many :properties

    def instance_method
      42
    end
  end

  class Org < JsonApiModel::Model
    wraps Example::Client::Org
  end

  class Blank < JsonApiModel::Model
    wraps Example::Client::Blank
  end

  class Option < JsonApiModel::Model
    wraps Example::Client::Option
  end
end

module FakeActiveRecord
  class Base
    attr_accessor :__attributes

    def initialize( args = {} )
      @__attributes = args.dup.with_indifferent_access
    end

    class << self
      def where( args = {} )
        [ new( args ) ]
      end

      def find( id )
        new id: id
      end
    end

    def method_missing( m, *args, &block )
      if __attributes.has_key? m.to_s
        __attributes[ m ]
      else
        super
      end
    end
  end
end

class Whatever < FakeActiveRecord::Base
end

class Something < FakeActiveRecord::Base
end

class Property < FakeActiveRecord::Base
end

class Nothing < FakeActiveRecord::Base
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