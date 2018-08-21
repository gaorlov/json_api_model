module JsonApiModel
  module Associations
    class HasMany < Has

      def action
        :where
      end
    end
  end
end
