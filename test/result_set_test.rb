require "test_helper"

class ResultSetTest < Minitest::Test
  def setup
    [ "http://example.com/users" ].each do |url|

      stub_request( :get, url )
        .to_return( headers: { content_type: "application/vnd.api+json" }, 
                    body: { data: [ { type: :users,
                                      id: 1,
                                      attributes: { name: "Greg" },
                                      links: { self: ""}
                                    } ], 
                            meta: { record_count: 1, page_count: 1 } }.to_json )
    end
    @scope    = Example::User.where
    @results  = @scope.all
  end

  def test_results_are_models
    assert @results.first.is_a?( JsonApiModel::Model )
  end

  def test_delegation
    ids = @scope.all.map( &:id )
    assert_equal [ 1 ], ids
  end

  def test_as_json
    assert_equal(
        { data: [ { "id" => 1, 
                    "type" => "users",
                    "attributes" => { "name" => "Greg" } } ],
          meta: { "record_count" => 1,
                  "page_count" => 1 } },
        @results.as_json )
  end

  def test_custom_as_json
    assert_equal(
        { d: [ 1 ],
          m: { count: 1 } },

        @results.as_json{ |data, meta|
          { d: data.map( &:id ),
            m: { count: meta[ "record_count" ] } }
        } )
  end
end
