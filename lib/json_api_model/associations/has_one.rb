module JsonApiModel
  module Associations
    class HasOne < Has
      include Flattable
    end
  end
end
