module JsonApiModel
  module Associations
    class HasOne < Has

      def action
        :find_by
      end
    end
  end
end
