module JsonApiModel
  class Model
    class << self
      extend Forwardable

      def_delegators :__new_scope, :where, :order, :includes, :select, :all, :paginate, :page, :with_params, :first, :find, :last

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

      private

      def __new_scope
        Scope.new( self )
      end
    end
    extend Forwardable

    attr_accessor :client

    def_delegators :client, :as_json

    def initialize( attributes = {} )
      @client = self.class.client_class.new( attributes )
    end

    def method_missing( m, *args, &block )
      client.send m, *args, &block
    end

    RESERVED_FIELDS = [ :type, :id ]
  end
end