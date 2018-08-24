module JsonApiModel
  module Associations
    module Flattable
      extend ActiveSupport::Concern

      included do
        def process( results )
          if flattable? results
            results.first
          else
            results
          end
        end

        private

        def flattable?( results )
          results.is_a?( JsonApiModel::ResultSet ) ||
          results.is_a?( Array ) ||
          results.is_a?( JsonApiModel::Scope ) ||
          results.respond_to?( :first )
        end
      end
    end
  end
end
