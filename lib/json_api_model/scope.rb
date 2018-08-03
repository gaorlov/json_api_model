module JsonApiModel
  class Scope
    def initialize( model_class )
      @model_class  = model_class
      @client_scope = JsonApiClient::Query::Builder.new( model_class.client_class )
    end

    def to_a
      @to_a ||= find
    end

    alias all to_a


    def find( args = {} )
      JsonApiModel.instrumenter.instrument 'find.json_api_model',
                                            args: args,
                                            url: url do
        results = @client_scope.find args
        ResultSet.new( results, @model_class )
      end
    end

    def first
      JsonApiModel.instrumenter.instrument 'first.json_api_model', url: url do
        @model_class.new_from_client @client_scope.first
      end
    end

    def last
      JsonApiModel.instrumenter.instrument 'last.json_api_model', url: url do
        @model_class.new_from_client @client_scope.last
      end
    end

    def params
      @client_scope.params
    end

    def method_missing( m, *args, &block )
      if @client_scope.respond_to? m
        @client_scope.send m, *args, &block
        self
      else
        all.send m, *args, &block
      end
    end

    private

    def url
      @model_class.client_class.requestor.send( :resource_path, params )
    end
  end
end