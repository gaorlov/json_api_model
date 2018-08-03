module JsonApiModel
  class Model
    class << self
      extend Forwardable

      def_delegators :_new_scope, :where, :order, :includes, :select, :all, :paginate, :page, :with_params, :first, :find, :last

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

      def _new_scope
        Scope.new( self )
      end
    end

    attr_accessor :client

    def initialize( attributes = {} )
      @client = self.class.client_class.new( attributes )
    end

    def method_missing( m, *args, &block )
      client.send m, *args, &block
    rescue NoMethodError
      raise NoMethodError, "No method `#{m}' found in #{self} or #{client}"
    end

    def as_json
      client.as_json
    end

    RESERVED_FIELDS = [ :type, :id ]
  end
end