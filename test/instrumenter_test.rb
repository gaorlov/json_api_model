require "test_helper"

class InstrumenterTest < Minitest::Test

  def setup
    [ "http://example.com/users?page%5Bpage%5D=1&page%5Bper_page%5D=1",
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
end
