require 'test_helper'

class AssociatableTest < Minitest::Test
  def test_belongs_to_adds_association
  end

  def test_belongs_to_adds_index
  end

  def test_has_one_adds_association
  end

  def test_has_many_adds_association
  end

  def test_belongs_to_correctly_queries
  end

  def test_has_one_correctly_queries
  end

  def test_has_many_correctly_queries
  end

  def test_through_correctly_queries
  end

  def test_polymorphic_associaitons_work
  end

  def test_polymorphic_associations_work_with_class_options
  end

  def test_polymorphic_belongs_to_can_call_association
  end

  def test_object_association_raises
    assert_raises do
      User.belongs_to :object
    end
  end

  def test_invalid_assocaition_options_raise
    assert_raises do
      User.belongs_to :thing, bad_option: :lol_fake
    end
    assert_raises do
      User.belongs_to :thing, through: :lol_fake
    end
    assert_raises do
      User.has_many :things, polymorphic: true
    end
  end

  def test_valid_association_with_no_value_does_not_raise
  end
end