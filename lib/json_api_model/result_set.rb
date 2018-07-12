module JsonApiModel
  class ResultSet
    def initialize( client_result_set, model_class )
      @set = client_result_set.clone
      @set.map! do | resource |
        model_class.new_from_client( resource )
      end
    end

    def as_json( opts = {} )
      if block_given?
        yield @set, meta
      else
        { data: @set.map(&:as_json),
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