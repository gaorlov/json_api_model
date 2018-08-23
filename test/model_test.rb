require "test_helper"

class ModelTest < Minitest::Test
  def setup
    [ "http://example.com/users" ].each do |url|

      stub_request( :get, url )
        .to_return( headers: { content_type: "application/vnd.api+json" }, body: { data: [], meta: { record_count: 1, page_count: 1} }.to_json )
    end
  end

  def test_scopes_delegate
    assert Example::User.where.is_a?( JsonApiModel::Scope )
  end

  def test_attributes_delegate
    model  = Example::User.new( id: 1 )

    assert_equal 1, model.id
  end

  def test_model_attributes
    model  = Example::User.new( id: 1 )

    assert_equal 42, model.instance_method
  end
end
