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

  def test_default_instumenter_is_innocuous
    JsonApiModel::Instrumenter::NullInstrumenter.new.instrument 'last.json_api_model', { payload: :value } do | payload |
      assert_equal( { payload: :value }, payload )
    end
  end
end
