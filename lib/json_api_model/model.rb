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
    end

    RESERVED_FIELDS = [ :type, :id ]
  end
end