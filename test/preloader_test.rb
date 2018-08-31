require 'test_helper'

    # belongs_to :org, class_name: "Example::Org"
    # has_one :blank
    # has_one :profile, class: Example::Profile
    # has_many :options, class_name: "Example::Option"

    # belongs_to :something
    # has_one :whatever
    # has_many :properties

    # has_many :intermediates
    # has_many :ends, through: :intermediates

    # has_one :banner, as: :thing, class_name: "Image"


class PreloaderTest < Minitest::Test
  def setup
    stub_request( :get, "http://example.com/users?ids=1,2,4" )
        .to_return( headers: { content_type: "application/vnd.api+json" }, 
                    body: { data: [{ type: :users,
                                    id: 1,
                                    attributes: { name: "Greg", something_id: 12 },
                                    links: { self: ""},
                                    relationships: {
                                      org: {
                                        data: { type: :orgs, id: 1 },
                                      },
                                      profile:{
                                        data: { type: :profiles, id: 1 },
                                      },
                                      options:{
                                        data: [
                                          { type: :options, id: 1 },
                                          { type: :options, id: 2 }
                                        ],
                                        links: { self: "", related: "" }
                                      },
                                    }
                                  },
                                  { type: :users,
                                    id: 2,
                                    attributes: { name: "Abby", something_id: 35 },
                                    links: { self: ""},
                                    relationships: {
                                      org: {
                                        data: { type: :orgs, id: 2 },
                                      },
                                      profile:{
                                        data: { type: :profiles, id: 2 },
                                      },
                                      options:{
                                        data: [
                                          { type: :options, id: 4 },
                                          { type: :options, id: 5 }
                                        ],
                                        links: { self: "", related: "" }
                                      },
                                    }
                                  },
                                  { type: :users,
                                    id: 4,
                                    attributes: { name: "Mike", something_id: 18 },
                                    links: { self: ""},
                                    relationships: {
                                      org: {
                                        data: { type: :orgs, id: 1 },
                                      },
                                      profile:{
                                        data: { type: :profiles, id: 4 },
                                      },
                                      options:{
                                        data: [
                                          { type: :options, id: 10 },
                                          { type: :options, id: 11 },
                                          { type: :options, id: 16 }
                                        ],
                                        links: { self: "", related: "" }
                                      },
                                    }
                                  }],
                            meta: { record_count: 1, page_count: 1 } }.to_json )

    @remote_belongs_to = Example::User.__associations[:org]
    @local_belongs_to  = Example::User.__associations[:something]

    @remote_has_one    = Example::User.__associations[:profile]
    @local_has_one     = Example::User.__associations[:whatever]

    @remote_has_many   = Example::User.__associations[:options]
    @local_has_many    = Example::User.__associations[:properties]

    @has_many_through  = Example::User.__associations[:ends]

    @bad_belongs_to  = Example::User.__associations[:bad_belongs]
    @bad_has_one     = Example::User.__associations[:bad_one]
    @bad_has_many    = Example::User.__associations[:bad_many]

    @users = Example::User.find( [ 1, 2, 4 ] )
    @greg = @users.select{ |u| u.id == 1 }.first
    @abby = @users.select{ |u| u.id == 2 }.first
    @mike = @users.select{ |u| u.id == 4 }.first
  end

  def test_preload_for_belongs_to_local
    loader = JsonApiModel::Associations::Preloaders::BelongsTo.new( @users, @local_belongs_to )
    loader.fetch

    @users.each do | user |
      assert user.__cached_associations[:something]
      assert_equal user.something_id, user.__cached_associations[:something].id
    end
  end

  def test_preload_for_belongs_to_remote
    stub_request(:get, "http://example.com/orgs?ids=1,2")
      .to_return( headers: { content_type: "application/vnd.api+json" }, 
                   body: { data: [{ type: :orgs,
                                    id: 1
                                  },
                                  # skip org 2
                                  # add bogus org
                                  { type: :orgs,
                                    id: 3
                                  }],
                            meta: { record_count: 2, page_count: 1 } }.to_json)


    loader = JsonApiModel::Associations::Preloaders::BelongsTo.new( @users, @remote_belongs_to )
    loader.fetch

    assert @greg.org
    assert_equal @greg.relationship_ids( :org ).first, @greg.org.id

    assert @mike.org
    assert_equal @mike.relationship_ids( :org ).first, @mike.org.id

    refute @abby.org
  end

  def test_preload_for_has_one_local
    loader = JsonApiModel::Associations::Preloaders::Has.new( @users, @local_has_one )
    loader.fetch

    @users.each do | user |
      assert user.__cached_associations[:whatever]
      assert_equal user.id, user.__cached_associations[:whatever].user_id
    end
  end


  def test_preload_for_has_one_remote
    stub_request(:get, "http://example.com/profiles?filter[id][0]=1&filter[id][1]=2&filter[id][3]=4")
      .to_return( headers: { content_type: "application/vnd.api+json" }, 
                   body: { data: [{ type: :profiles, id: 1 },
                                  { type: :profiles, id: 2 }],
                                  # no profile for mike lol
                            meta: { record_count: 2, page_count: 1 } }.to_json)


    loader = JsonApiModel::Associations::Preloaders::Has.new( @users, @remote_has_one )
    loader.fetch

    assert @greg.profile
    assert_equal 1, @greg.profile.id

    assert @abby.profile
    assert_equal 2, @abby.profile.id
    
    refute @mike.profile
  end

  def test_preload_for_has_many_local
    loader = JsonApiModel::Associations::Preloaders::Has.new( @users, @local_has_many )
    loader.fetch

    @users.each do | user |
      assert user.__cached_associations[:properties]
      assert user.__cached_associations[:properties].all?{ |property| property.user_id == user.id }
    end
  end


  def test_preload_for_has_many_remote
    stub_request(:get, "http://example.com/options?filter[id][0]=1&filter[id][1]=2&filter[id][3]=4&filter[id][4]=5&filter[id][5]=10&filter[id][6]=11&filter[id][7]=16")
      .to_return( headers: { content_type: "application/vnd.api+json" }, 
                   body: { data: [{ type: :options, id: 1 },
                                  { type: :options, id: 2 },
                                  { type: :options, id: 4 },
                                  { type: :options, id: 5 },
                                  { type: :options, id: 10 },
                                  # skip a resource
                                  { type: :options, id: 16 },
                                  # why did you even send me this?
                                  { type: :options, id: 18 },
                                ],
                            meta: { record_count: 7, page_count: 1 } }.to_json)


    loader = JsonApiModel::Associations::Preloaders::Has.new( @users, @remote_has_many )
    loader.fetch

    assert @greg.options
    assert_equal [ 1, 2 ], @greg.options.map( &:id )

    assert @abby.options
    assert_equal [ 4, 5 ], @abby.options.map( &:id )

    assert @mike.options
    assert_equal [ 10, 16 ], @mike.options.map( &:id )
  end

  def test_preload_for_has_many_local_through
    loader = JsonApiModel::Associations::Preloaders::Has.new( @users, @has_many_through )
    loader.fetch

    @users.each do | user |
      assert user.__cached_associations[:ends]
      assert user.__cached_associations[:ends].all?{ |e| e.id }
    end
  end

  def test_preload_for_remote_belongs_to_with_errors
    stub_request(:get, "http://example.com/orgs?ids=1,2")
      .to_return( headers: { content_type: "application/vnd.api+json" }, 
                  # garbage data is garbage
                  body: { data: [{ type: :orgs }],
                          meta: { record_count: 1, page_count: 1 } }.to_json)


    loader = JsonApiModel::Associations::Preloaders::Has.new( @users, @remote_belongs_to )
    assert_raises do
      loader.fetch
    end
  end

  def test_preload_for_has_errors
    stub_request(:get, "http://example.com/profiles?filter[id][0]=1&filter[id][1]=2&filter[id][3]=4")
      .to_return( headers: { content_type: "application/vnd.api+json" }, 
                   body: { data: [{ type: :profiles, id: 1 },
                                  # garbage data is garbage
                                  { type: :profiles }],
                                  # no profile for mike lol
                            meta: { record_count: 2, page_count: 1 } }.to_json)


    loader = JsonApiModel::Associations::Preloaders::BelongsTo.new( @users, @remote_has_one )
    assert_raises do
      loader.fetch
    end
  end

  def test_preload_belongs_to_remote_with_no_relationship
    skip
  end

  def test_preload_has_one_remote_with_no_relationship
    skip
  end

  def test_preload_has_many_remote_with_no_relationship
    skip
  end

  def test_preload_for_belongs_to_local
    loader = JsonApiModel::Associations::Preloaders::BelongsTo.new( @users, @bad_belongs_to )
    assert_raises do
      loader.fetch
    end
  end

  def test_preload_for_has_one_local
    loader = JsonApiModel::Associations::Preloaders::Has.new( @users, @bad_has_one )
    assert_raises do
      loader.fetch
    end
  end

  def test_preload_for_has_many_local
    loader = JsonApiModel::Associations::Preloaders::Has.new( @users, @bad_has_many )
    assert_raises do
      loader.fetch
    end
  end

  def test_preloader_fetches_association
    preloader = JsonApiModel::Associations::Preloaders.preloader_for( @users, :org )
    assert preloader
    assert preloader.is_a? JsonApiModel::Associations::Preloaders::BelongsTo
  end

  def test_preloader_association_error
    assert_raises do
      JsonApiModel::Associations::Preloaders.preloader_for( @users, :not_a_thing )
    end
  end

  def tes_preloader_base
    preloader = JsonApiModel::Associations::Preloader.new( @users, [ :org, :options ] )
    
    assert_equal [ :org, :options ], prelaoder.preloads
  end

  def test_preloader

    org_stub = stub_request( :get, "http://example.com/orgs?ids=1,2")
                  .to_return( headers: { content_type: "application/vnd.api+json" }, 
                               body: { data: [{ type: :orgs, id: 1 }],
                                        meta: { record_count: 2, page_count: 1 } }.to_json)

    options_stub = stub_request(:get, "http://example.com/options?filter[id][0]=1&filter[id][1]=2&filter[id][3]=4&filter[id][4]=5&filter[id][5]=10&filter[id][6]=11&filter[id][7]=16")
                      .to_return( headers: { content_type: "application/vnd.api+json" }, 
                                   body: { data: [{ type: :options, id: 1 },
                                                  { type: :options, id: 2 },
                                                  { type: :options, id: 4 },
                                                  { type: :options, id: 5 },
                                                  { type: :options, id: 10 },
                                                  { type: :options, id: 16 }],
                                            meta: { record_count: 7, page_count: 1 } }.to_json)

    users = Example::User.find( [ 1, 2, 4 ] )
    greg = users.select{ |u| u.id == 1 }.first
    abby = users.select{ |u| u.id == 2 }.first
    mike = users.select{ |u| u.id == 4 }.first

    JsonApiModel::Associations::Preloader.preload( users, :org, :options, :properties )

    assert greg.org
    assert_equal 1, greg.org.id

    refute abby.org

    assert greg.options
    assert_equal [ 1, 2 ], greg.options.map( &:id )

    assert abby.options
    assert_equal [ 4, 5 ], abby.options.map( &:id )

    assert mike.options
    assert_equal [ 10, 16 ], mike.options.map( &:id )

    users.each do | user |
      assert user.__cached_associations[:properties]
    end

    assert_requested org_stub, times: 1
    assert_requested options_stub, times: 1
  end

  def test_preloader_with_nested_preloads
    skip
    JsonApiModel::Associations::Preloader.preload( @users, intermediates: [ :ends ])
  end
end
