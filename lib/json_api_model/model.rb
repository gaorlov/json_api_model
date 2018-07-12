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
    end

    def as_json
      client.as_json
    end

    RESERVED_FIELDS = [ :type, :id ]
  end
end