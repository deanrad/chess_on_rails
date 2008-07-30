require File.dirname(__FILE__) + '/../test_helper'

class PositionTest < ActiveSupport::TestCase

  def setup
    @a5 = Position.new( 'a', '5' )
    @b4 = Position.new( 'b4' )
    @d3 = Position.new( :d3 )
  end
  
  def test_each_position_has_symbol_defined
    #test one to show our point
    assert Symbol.all_symbols.any? { |sym| sym.to_s == Position::POSITIONS[0] }
  end
  
  def test_cannot_have_instance_of_invalid_position
    assert_raises InvalidPositionError do
      p = Position.new( 'a9' )
    end
    assert_raises InvalidPositionError do
      p = Position.new( 'to_long' )
    end
  end
  
  def test_can_be_displayed_as_string
    assert_equal 'd3', @d3.to_s
  end
  
  def test_can_add_via_vector_if_stays_on_board
    p = @a5 + [1,0]
    assert_equal :b5, p.to_sym  
  end

  def test_can_detect_if_add_via_vector_falls_off_board
     p = @a5 + [5,5]
     assert ! p.valid?
  end

  def test_adding_nonsensical_things_to_position_invalidates_it
    p = @a5 + 'ten'
    assert ! p.valid?
  end
      
end
