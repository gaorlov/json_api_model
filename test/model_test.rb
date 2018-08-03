require "test_helper"

class ModelTest < Minitest::Test
  def setup
    [ "http://example.com/users/search?q=Gregzilla",
      "http://example.com/users" ].each do |url|
      stub_request( :get, url )
        .to_return( headers: { content_type: "application/vnd.api+json" }, body: { data: [ { id: 1, attributes: { name: "Gregzilla" } } ], meta: { record_count: 1, page_count: 1 } }.to_json )
    end

    stub_request(:post, "http://example.com/users").
      with(
        body: { data:{ type: "users",
                       attributes:{ name: "Greg"}}}.to_json,
        headers: {
        'Accept'=>'application/vnd.api+json',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type'=>'application/vnd.api+json',
        'User-Agent'=>'Faraday v0.15.2'
        }).to_return(headers: {status: 200, content_type: "application/vnd.api+json"}, body: {
        data: {
          type: "users",
          id: "1",
          attributes: {
            name: "Greg"
          }
        }
      }.to_json )

    stub_request(:patch, "http://example.com/users/1").
      with(
        body: { data:{ id: "1",
                       type: "users",
                       attributes:{ name: "Greg O"}}}.to_json,
        headers: {
        'Accept'=>'application/vnd.api+json',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type'=>'application/vnd.api+json',
        'User-Agent'=>'Faraday v0.15.2'
        }).to_return(headers: {status: 200, content_type: "application/vnd.api+json"}, body: {
        data: {
          type: "users",
          id: "1",
          attributes: {
            name: "Greg O"
          }
        }
      }.to_json )

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

  def test_class_methods_delegate
    assert_equal :also_42, Example::User.class_method
    assert_equal :something, Example::User.base_class_method
  end

  def test_custom_methods_delagate
    response = Example::User.search q: "Gregzilla"
    assert_equal JsonApiModel::ResultSet, response.class
  end

  def test_custom_methods_wrap_clients
    response = Example::User.lucky_search q: "Gregzilla"
    assert_equal Example::User, response.class
  end

  def test_custom_methods_wrap_clients
    response = Example::User.create name: "Greg"
    assert_equal Example::User, response.class
  end

  def test_connection_is_ovveridable
    connection = Example::User.client_class.connection

    assert_equal "http://example.com/", Example::User.connection.faraday.url_prefix.to_s

    Example::User.site = "http://google.com/api/"

    Example::User.connection do | conn |
      # i don't need to do anything here
    end

    assert_equal "http://google.com/api/", Example::User.connection.faraday.url_prefix.to_s

    # cleanup. other tests need this site to not be google
    Example::User.site = "http://example.com/"

    Example::User.connection do | conn |
    end
  end

  def test_method_missings_raise_helpful_errors
    user = Example::User.new
    exception = assert_raises NoMethodError do
      user.id
    end

    assert_equal "No method `id' found in #{user} or #{user.client}", exception.message

    exception = assert_raises NoMethodError do
      Example::User.not_a_method
    end

    assert_equal "No method `not_a_method' found in Example::User or Example::Client::User", exception.message
  end

  def test_member_requests
    user = Example::User.new name: "Greg"
    assert user.save

    assert user.update_attributes name: "Greg O"
    assert_equal "Greg O", user.name

    assert_equal Example::User, user.class
  end
end
