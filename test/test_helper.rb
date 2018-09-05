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

    class Blank < Base
    end

    class Profile < Base
    end

    class Option < Base
    end

    class Org < Base
    end

    class Industry < Base
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

    has_many :intermediates
    has_many :ends, through: :intermediates

    has_one :banner, as: :thing, class_name: "Image"


    belongs_to :bad_belongs
    has_one :bad_one
    has_many :bad_many

    def instance_method
      42
    end

    def self.class_method
      :also_42
    end

    def bad_belongs_id
      8
    end
  end

  class Org < JsonApiModel::Model
    wraps Example::Client::Org

    belongs_to :industry, class_name: "Example::Industry"
  end

  class Industry < JsonApiModel::Model
    wraps Example::Client::Industry
  end

  class Blank < JsonApiModel::Model
    wraps Example::Client::Blank
  end

  class Option < JsonApiModel::Model
    wraps Example::Client::Option
  end
end


module FakeActiveRecord
  class Relation
    def initialize( args, records )
      @__records = records
    end

    def first
      @__records.first
    end

    def preload( *args )
      self
    end

    def to_a
      self
    end

    def method_missing( m, *args, &block )
      @__records.send m, *args, &block
    end
  end

  class Base
    attr_accessor :__attributes

    def initialize( args = {} )
      @__attributes = args.dup.with_indifferent_access
      @__attributes[:id] ||= self.class.id
    end

    class_attribute :__id
    self.__id = 0
    class << self
      def id
        self.__id += 1
      end

      def where( args = {} )
        r = args.each_with_object([]) do | ( k, v ), results |
          Array(v).each do |value|
            results << new( k => value )
          end
        end
        Relation.new args, r
      end

      def find( opts )
        case opts
        when Array
          opts.map{ |id| find id }
        when Integer
          new id: opts
        when Hash
          where opts
        end
      end
    end

    def method_missing( m, *args, &block )
      if __attributes.has_key? m.to_s
        __attributes[ m ]
      else
        super
      end
    end

    def respond_to_missing?( m, include_private = false )
      __attributes.has_key? m.to_s || super
    end
  end
end

class Image < FakeActiveRecord::Base
  def thing_id
    1
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

class End < FakeActiveRecord::Base
end

class Mean < FakeActiveRecord::Base
end

class BadBelong < FakeActiveRecord::Base
  def initialize( args = {} )
    @__attributes = {}
  end
end

class BadOne < FakeActiveRecord::Base
  def initialize( args = {} )
    @__attributes = {}
  end
end

class BadMany < FakeActiveRecord::Base
  def initialize( args = {} )
    @__attributes = {}
  end
end


class Intermediate < FakeActiveRecord::Base
  def initialize( args = {} )
    super
    @__attributes[:end_id] = 1
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