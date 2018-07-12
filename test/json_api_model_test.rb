require "test_helper"

class JsonApiModelTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::JsonApiModel::VERSION
  end

  def test_instrumenter_assignemnt
    JsonApiModel.instrumenter = DummyInstrumenter.new

    assert JsonApiModel.instrumenter.is_a?( DummyInstrumenter )
  end
end
