module JsonApiModel
  module Instrumenter
    class NullInstrumenter
      def instrument( name, payload = {} )
        yield payload
      end
    end
  end
end