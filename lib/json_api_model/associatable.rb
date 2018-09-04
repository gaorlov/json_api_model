module JsonApiModel
  module Associatable
    extend ActiveSupport::Concern

    included do

      class_attribute :__associations
      self.__associations = {}

      attr_accessor :__cached_associations

      def has_relationship_ids?( name )
        !!relationships[ name ]
      end

      def relationship_ids( name )
        relationships_data = relationships[ name ]&.dig( :data )
        case relationships_data
        when Hash
          [ relationships_data[ :id ] ]
        when Array
          relationships_data.map{ | datum | datum[ :id ] }
        when NilClass
          [ ]
        else
          raise "Unexpected relationship data type: #{relationships_data.class}"
        end
      end

      class << self

        def belongs_to( name, opts = {} )
          process Associations::BelongsTo.new( self, name, opts )
        end

        def has_one( name, opts = {} )
          process Associations::HasOne.new( self, name, opts )
        end

        def has_many( name, opts = {} )
          process Associations::HasMany.new( self, name, opts )
        end
        
        protected

        def process( association )
          associate association
          methodize association
        end

        def associate( association )
          self.__associations = __associations.merge association.name => association
        end

        def methodize( association )
          define_method association.name do
            self.__cached_associations ||= {}

            unless self.__cached_associations.has_key? association.name
              self.send( "#{association.name}=", association.fetch( self ) )
            end
            self.__cached_associations[association.name]
          end

          define_method "#{association.name}=" do | value |
            self.__cached_associations ||= {}
            self.__cached_associations[association.name] = value
          end
        end
      end
    end
  end
end