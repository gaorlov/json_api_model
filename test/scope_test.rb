require "test_helper"

class ScopeTest < Minitest::Test
  def setup
    [ "http://example.com/users" ].each do |url|

      stub_request( :get, url )
        .to_return( headers: { content_type: "application/vnd.api+json" }, 
                    body: { data: [ { type: :users,
                                      id: 1,
                                      attributes: { name: "Greg" },
                                      links: { self: ""},
                                      relationships: {
                                        org: {
                                          data: { type: :orgs, id: 1 },
                                        }
                                      }
                                    } ], 
                            meta: { record_count: 1, page_count: 1 } }.to_json )
    end
    @scope = Example::User.where
  end

  def test_scope_to_a
    results = @scope.to_a
    assert results.is_a?( JsonApiModel::ResultSet )
  end

  def test_scope_chains
    assert @scope.where( id: 1 ).is_a?( JsonApiModel::Scope)
    assert_equal( { filter:{ id: 1, name: "Greg" } }, @scope.where( id: 1 ).where( name: "Greg" ).params )
  end

  def test_scope_delegates_to_results
    ids = @scope.map( &:id )
    assert_equal [ 1 ], ids
  end

  def test_preload_for_local_models
    users = Example::User.preload( :whatever )
    users.each do | user |
      assert user.__cached_associations[:whatever]
    end
  end

  def test_preload_for_remote_models
    org_stub = stub_request(:get, "http://example.com/orgs?ids=1")
                  .to_return( headers: { content_type: "application/vnd.api+json" }, 
                              body: { data: { type: :orgs, id: 1 },
                                      meta: { record_count: 2, page_count: 1 } }.to_json)
                
    users = Example::User.preload( :org )
    users.each do | user |
      assert user.org
    end
    assert_requested org_stub, times: 1
  end
end
