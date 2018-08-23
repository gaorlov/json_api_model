require "test_helper"

class InstrumenterTest < Minitest::Test

  def setup
    [ "http://example.com/users?page[page]=1&page[per_page]=1",
      "http://example.com/users"].each do |url|

      stub_request( :get, url )
        .to_return( headers: { content_type: "application/vnd.api+json" }, body: { data: [] }.to_json )
    end
  end

  def test_find
    Example::User.find

    assert 'find.json_api_model', JsonApiModel.instrumenter.last_event[:name]
  end

  def test_first
    Example::User.first

    assert 'first.json_api_model', JsonApiModel.instrumenter.last_event[:name]
  end

  def test_last
    Example::User.last

    assert 'last.json_api_model', JsonApiModel.instrumenter.last_event[:name]
  end

  def test_null_instrumenter_doesnt_mangle_payload
    instrumenter = JsonApiModel::Instrumenter::NullInstrumenter.new

    instrumenter.instrument( "event", "payload" ) do |blah|
      assert_equal "payload", blah
    end
  end
end
