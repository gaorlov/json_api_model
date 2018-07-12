require "test_helper"

class ScopeTest < Minitest::Test
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
    @scope = Example::User.where
  end

  def test_scope_to_a
    results = @scope.to_a
    assert results.is_a?( JsonApiModel::ResultSet )
  end

  def test_scope_chains
    assert @scope.where( id: 1 ).is_a?( JsonApiModel::Scope)
  end

  def test_scope_delegates_to_results
    ids = @scope.map( &:id )
    assert_equal [ 1 ], ids
  end
end
