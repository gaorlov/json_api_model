module JsonApiModel
  class ResultSet
    def initialize( client_result_set, resource_class )
      @set = client_result_set
    end

    def as_json( opts = {} )
      if block_given?
        yield @set, meta
      else
        { data: @set,
          meta: meta
        }
      end
    end

    def meta
      @set.meta.attributes
    end

    def method_missing( m, *args, &block )
      @set.send m, *args, &block
    end
  end
end