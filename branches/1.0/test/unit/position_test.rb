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
  
  def test_can_be_displayed_as_string
    assert_equal 'd3', @d3.to_s
  end
  
  def test_can_add_via_vector_if_stays_on_board
    #a move toward black one unit from a5
    p = @a5 + [1,0] 
    assert_equal :a6, p.to_sym  
    assert_equal :a5, @a5.to_sym #original remains unaltered
  end

  def test_can_detect_if_add_via_vector_falls_off_board
     p = @a5 + [5,5]
     assert ! p.valid?
  end

  def test_adding_nonsensical_things_to_position_invalidates_it
    p = @a5 + 'ten'
    assert ! p.valid?
  end

  def test_concise_way_to_call_constructor
    assert_equal :d4, Position.as_symbol('d', 4)
  end      
end
