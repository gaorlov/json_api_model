module JsonApiModel
  class Scope
    def initialize( model_class )
      @model_class  = model_class
      @client_scope = JsonApiClient::Query::Builder.new( model_class.client_class )
      @cache        = {}
    end

    def find( args = {} )
      JsonApiModel.instrumenter.instrument 'find.json_api_model',
                                            args: args,
                                            url: url do
        cache_or_find args do
          results = @client_scope.find args
          ResultSet.new( results, @model_class )
        end
      end
    end

    alias to_a find
    alias all find

    def first
      JsonApiModel.instrumenter.instrument 'first.json_api_model', url: url do
        # if the non-first query has already been executed, there's no need to make the call again
        if cached?
          cache.first
        else
          cache_or_find :first do
            @model_class.new_from_client @client_scope.first
          end
        end
      end
    end

    def last
      JsonApiModel.instrumenter.instrument 'last.json_api_model', url: url do
        # this is a separate call always because the last record may exceed page size
        cache_or_find :last do
          @model_class.new_from_client @client_scope.last
        end
      end
    end

    def method_missing( m, *args, &block )
      if @client_scope.respond_to? m
        _new_scope @client_scope.send( m, *args, &block )
      else
        all.send m, *args, &block
      end
    end

    attr_accessor :client_scope
    delegate :params, to: :client_scope

    private

    def _new_scope( client_scope )
      self.class.new( @model_class ).tap do |scope|
        scope.client_scope = client_scope
      end
    end

    def cached?
      @cache.has_key? keyify
    end

    def cache
      @cache[keyify]
    end

    # because a scope can be modified and then resolved, we want to cache by the full param set
    def cache_or_find( opts = {} )
      key = keyify( opts )
      @cache.fetch key do |key|
        @cache[key] = yield
      end
    end

    def keyify( opts = {} )
      params.merge( hashify( opts ) ).sort.to_s
    end

    def hashify( opts = {} )
      case opts
      when Hash
        opts
      else
        { opt: opts }
      end
    end

    def url
      @model_class.client_class.requestor.send( :resource_path, params )
    end
  end
end