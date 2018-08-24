require 'test_helper'

class AssociatableTest < Minitest::Test
  def setup
    stub_request( :get, "http://example.com/users/1" )
        .to_return( headers: { content_type: "application/vnd.api+json" }, 
                    body: { data: { type: :users,
                                    id: 1,
                                    attributes: { name: "Greg", something_id: 12 },
                                    links: { self: ""},
                                    relationships: {
                                      blank: {
                                        data: nil,
                                        links: { self: "" }
                                      },
                                      org: {
                                        data: { type: :orgs, id: 1 },
                                        links: { self: "" }
                                      },
                                      profile:{
                                        data: { type: :profiles, id: 1 },
                                        links: { self: "" }
                                      },
                                      options:{
                                        data: [
                                          { type: :options, id: 1 },
                                          { type: :options, id: 2 }
                                        ],
                                        links: { self: "", related: "" }
                                      },
                                      malformed:{
                                        data: 6,
                                        links: {self: "", related: ""}
                                      }
                                    }
                                  }, 
                            meta: { record_count: 1, page_count: 1 } }.to_json )

    stub_request( :get, "http://example.com/users/2" )
        .to_return( headers: { content_type: "application/vnd.api+json" }, 
                    body: { data: { type: :users,
                                    id: 2,
                                    attributes: { name: "Abby" },
                                    links: { self: ""}
                                  },
                            meta: { record_count: 1, page_count: 1 } }.to_json )

    stub_request(:get, "http://example.com/orgs?filter[id][0]=1")
        .to_return( status: 200,
                    headers: { content_type: 'application/vnd.api+json' },
                    body: { data: [ { type: :orgs,
                                      id: 1,
                                      attributes: { name: "ACME, Inc." },
                                      links: { self: ""}
                                    }
                                  ],
                            meta: { record_count: 1, page_count: 1 } }.to_json )

    stub_request(:get, "http://example.com/profiles?filter[id][0]=1&page[page]=1&page[per_page]=1")
        .to_return( status: 200,
                    headers: { content_type: 'application/vnd.api+json' },
                    body: { data: [ { type: :profiles,
                                      id: 1,
                                      attributes: { type: "baller hyperadmin" },
                                      links: { self: ""}
                                    }
                                  ],
                            meta: { record_count: 1, page_count: 1 } }.to_json )

  [ "http://example.com/options?filter[id][0]=1&filter[id][1]=2",
    "http://example.com/options?filter[id][0]=1&filter[id][1]=2&page[page]=1&page[per_page]=1" ].each do |url|
      stub_request(:get, url)
        .to_return( status: 200,
                    headers: { content_type: 'application/vnd.api+json' },
                    body: { data: [ { type: :options,
                                      id: 1,
                                      attributes: { name: "opt", value: "value" },
                                      links: { self: ""}
                                    },
                                    { type: :options,
                                      id: 2,
                                      attributes: { name: "opt", value: "value" },
                                      links: { self: ""}
                                    }
                                  ],
                            meta: { record_count: 1, page_count: 1 } }.to_json )
    end

    @user1 = Example::User.find( 1 ).first
    @user2 = Example::User.find( 2 ).first
  end

  def test_belongs_to_adds_association
    Example::User.belongs_to :nothing
    assert_equal [ :org, :blank, :profile, :options, :something, :whatever, :properties, :intermediates, :ends, :nothing ], Example::User.__associations.keys
    assert_equal JsonApiModel::Associations::BelongsTo, Example::User.__associations.values.last.class
  end

  def test_has_one_adds_association
    Example::User.has_one :nothing
    assert_equal [ :org, :blank, :profile, :options, :something, :whatever, :properties, :intermediates, :ends, :nothing ], Example::User.__associations.keys
    assert_equal JsonApiModel::Associations::HasOne, Example::User.__associations.values.last.class
  end

  def test_has_many_adds_association
    Example::User.has_many :nothing
    assert_equal [ :org, :blank, :profile, :options, :something, :whatever, :properties, :intermediates, :ends, :nothing ], Example::User.__associations.keys
    assert_equal JsonApiModel::Associations::HasMany, Example::User.__associations.values.last.class
  end

  def test_has_relationship_ids?
    assert @user1.has_relationship_ids? :org
    assert @user1.has_relationship_ids? :profile
    assert @user1.has_relationship_ids? :options
    assert @user1.has_relationship_ids? :blank

    refute @user1.has_relationship_ids? :not_a_relationship
    refute @user2.has_relationship_ids? :org
  end

  def test_relationship_ids
    assert_equal [1],     @user1.relationship_ids( :org )
    assert_equal [1],     @user1.relationship_ids( :profile )
    assert_equal [1, 2],  @user1.relationship_ids( :options )
    assert_equal [],      @user1.relationship_ids( :blank )

    assert_equal [],      @user1.relationship_ids( :not_a_relationship )
    assert_equal [],      @user2.relationship_ids( :org )
    assert_raises do
      @user1.relationship_ids :malformed
    end
  end

  def test_belongs_to_correctly_queries_relationship
    assert @user1.org
    assert_equal 1, @user1.org.id
    assert_equal "ACME, Inc.", @user1.org.name
  end

  def test_belongs_to_correctly_queries_attribute_id
    assert @user1.something
    assert_equal 12, @user1.something.id
  end

  def test_has_one_correctly_queries_relationship
    assert @user1.profile
    assert_equal 1, @user1.profile.id
    assert_equal "baller hyperadmin", @user1.profile.type
  end

  def test_has_one_correctly_queries_by_model_id
    assert @user1.whatever
    assert 1, @user1.whatever.user_id
  end

  def test_has_many_correctly_queries_relationship
    assert @user1.options
    assert_equal [ 1, 2 ], @user1.options.map( &:id )
    assert_equal "value", @user1.options.first.value
  end

  def test_has_many_correctly_queries_by_model_id
    assert @user1.properties
    assert [ 1 ], @user1.properties.map( &:user_id )
  end

  def test_through_correctly_queries_by_model_id
    assert @user1.ends
    assert_equal [1], @user1.ends.map(&:id)
  end

  def test_find_caches
    stub = stub_request( :get, "http://example.com/users?filter[name]=Greg" )
            .to_return( headers: { content_type: "application/vnd.api+json" },
                        body: { data: { type: :users,
                                    id: 1,
                                    attributes: { name: "Greg" },
                                    links: { self: ""}
                                  },
                                meta: { record_count: 1, page_count: 1 } }.to_json )
    scope = Example::User.where( name: "Greg" )

    scope.all
    scope.all

    assert_requested stub, times: 1
  end

  def test_first_pulls_from_cache
    stub = stub_request( :get, "http://example.com/users?filter[name]=Greg" )
            .to_return( headers: { content_type: "application/vnd.api+json" },
                        body: { data: { type: :users,
                                    id: 1,
                                    attributes: { name: "Greg" },
                                    links: { self: ""}
                                  },
                                meta: { record_count: 1, page_count: 1 } }.to_json )
    scope = Example::User.where( name: "Greg" )

    scope.all
    scope.first

    assert_equal scope.all.first, scope.first

    assert_requested stub, times: 1
  end

  def test_object_association_raises
    assert_raises do
      Example::User.belongs_to :object
    end
  end

  def test_invalid_assocaition_options_raise
    assert_raises do
      Example::User.belongs_to :thing, bad_option: :lol_fake
    end
    assert_raises do
      Example::User.belongs_to :thing, through: :lol_fake
    end
    assert_raises do
      Example::User.has_many :things, polymorphic: true
    end
  end

  def test_valid_association_with_no_value_does_not_raise
  end
end