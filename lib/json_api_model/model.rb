module JsonApiModel
  class Model
    class << self
      delegate :where, :order, :includes, :select, :all, :paginate, :page, :with_params, :first, :find, :last, to: :__new_scope

      attr_reader :client_class
      def wraps( client_class )
        @client_class = client_class
      end

      def new_from_client( client )
        model = new
        model.client = client
        model
      end

      def connection( &block )
        client_class.connection true, &block
      end

      def method_missing( m, *args, &block )
        result = client_class.send m, *args, &block
        case result
        when JsonApiClient::ResultSet
          JsonApiModel::ResultSet.new( result, self )
        when client_class
          new_from_client result
        else
          result
        end
      rescue NoMethodError
        raise NoMethodError, "No method `#{m}' found in #{self} or #{client_class}"
      end

      private

      def __new_scope
        Scope.new( self )
      end
    end
    include Associatable
    
    attr_accessor :client

    delegate :as_json, to: :client

    def initialize( attributes = {} )
      @client = self.class.client_class.new( attributes )
    end

    def method_missing( m, *args, &block )
      client.send m, *args, &block
    rescue NoMethodError
      raise NoMethodError, "No method `#{m}' found in #{self} or #{client}"
    end

    RESERVED_FIELDS = [ :type, :id ]
  end
end