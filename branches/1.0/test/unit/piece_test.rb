require File.dirname(__FILE__) + '/../test_helper'

class PieceTest < ActiveSupport::TestCase

  def setup
    @k   = Piece.new( :king, :white )
    @wb  = Piece.new( :bishop, :white )
    @bq  = Piece.new( :queen, :black )
    @br  = Piece.new( :rook, :black, :queens )
    @wkb = Piece.new( :bishop, :white, :kings )
  end
  
  def test_can_create_pieces
    [@k, @wb, @wkb].each{ |p| assert_not_nil p }
  end
  
  def test_needs_to_know_which_for_side_id
    assert_raises AmbiguousPieceError do
      puts @wb.side_id
    end
  end
  
  def test_knows_side_id_given_sufficient_information
    assert_equal :kings_bishop, @wkb.side_id
  end
  
  def test_knows_board_id_given_sufficient_information
    assert_equal :black_queen, @bq.board_id
  end
  
  def test_bishop_moves_in_any_diagonal_direction
    assert_equal 4, @wb.lines_of_attack.length
    move_vectors = @wb.lines_of_attack.collect(&:vector)
    assert move_vectors.include?( [1,1] )
    assert move_vectors.include?( [-1,1] )
    assert move_vectors.include?( [1,-1] )
    assert move_vectors.include?( [-1,-1] )
  end
  
  def test_rook_moves_in_any_straight_direction
    assert_equal 4, @br.lines_of_attack.length    
    move_vectors = @br.lines_of_attack.collect(&:vector)
    [[1,0], [-1,0], [0,1], [0,-1]].each do |vector|
      assert move_vectors.include?(vector)
    end
  end

  def test_queen_moves_like_bishop_and_rook_combined
    assert_equal 8, @bq.lines_of_attack.length    
  end
  
  #TODO fill out more tests for completeness and documentation sake
end
