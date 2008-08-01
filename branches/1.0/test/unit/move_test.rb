require File.dirname(__FILE__) + '/../test_helper'

class MoveTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_can_create_a_move_with_valid_from_and_to_coordinates_as_symbols
    m = Move.create(:from_coord => :a2, :to_coord => :a4)
    assert_equal :a2, m.from_coord 
    assert_equal :a4, m.to_coord 
  end
  
  def test_move_comes_back_from_database_as_symbols
    assert_equal :d4, matches(:dean_vs_maria).moves.first.to_coord
  end
end
