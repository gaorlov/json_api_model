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
                                    }
                                  },
                                  { type: :users,
                                    id: 2,
                                    attributes: { name: "Abby", something_id: 35 },
                                    links: { self: ""},
                                    relationships: {
                                      org: {
                                        data: { type: :orgs, id: 2 },
                                        links: { self: "" }
                                      },
                                      profile:{
                                        data: { type: :profiles, id: 2 },
                                        links: { self: "" }
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
                                        links: { self: "" }
                                      },
                                      profile:{
                                        data: { type: :profiles, id: 4 },
                                        links: { self: "" }
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

    @users = Example::User.find( [ 1, 2, 4 ] )
  end

  def test_preload_for_local_models
    loader = JsonApiModel::Associations::Preloaders::Has.new( @users, @remote_belongs_to )
  end

  def text_preload_for_remote_models
    skip
  end
end
