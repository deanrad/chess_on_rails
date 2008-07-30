require File.dirname(__FILE__) + '/../test_helper'

class BoardTest < ActiveSupport::TestCase
  def setup
    @rook = Piece.new(:rook )
    @white_king, @white_queen = [ Piece.new(:king, :white), Piece.new(:queen, :white) ]
    @black_king, @black_queen = [ Piece.new(:king, :black), Piece.new(:queen, :black) ]
    
    @lone_rook_board = Board[ :a1 => @rook ]
    @kings_and_queens= Board[ :d1 => @white_queen, :e1 => @white_king, :d8 => @black_queen, :e8 => @black_king ]
  end
  
  # Replace this with your real tests.
  def test_board_can_store_a_piece
    assert_equal :rook, @lone_rook_board[:a1].role
  end

  def test_board_can_move_piece_when_none_other_on_board # :nodoc:
    piece_moved = @lone_rook_board.move!( Move.new( :from_coord => :a1, :to_coord => :a4) )
    assert_equal @rook, piece_moved
    assert_nil @lone_rook_board[:a1]
  end
  
  def test_board_can_consider_move_and_revert # :nodoc:
    assert_equal @rook, @lone_rook_board[:a1]
    
    @lone_rook_board.consider_move( Move.new( :from_coord => :a1, :to_coord => :a8) ) do
      assert_nil @lone_rook_board[:a1]
      assert_equal @rook, @lone_rook_board[:a8]
    end
    
    assert_equal @rook, @lone_rook_board[:a1]
  end
  
  def test_can_capture_a_piece_on_board_by_moving_onto_its_square
    @kings_and_queens.move!( Move.new( :from_coord => :d8, :to_coord => :d1) )  #daring Queen capture
    assert_equal 3, @kings_and_queens.squares_occupied.length
    assert_equal :black, @kings_and_queens[:d1].side
  end

  def test_capture_is_undone_when_only_considering # :nodoc:
    @kings_and_queens.consider_move( Move.new( :from_coord => :d8, :to_coord => :d1) )  do
      assert_equal 3, @kings_and_queens.squares_occupied.length
      assert_equal :black, @kings_and_queens[:d1].side
    end
    assert_equal 4, @kings_and_queens.squares_occupied.length
    assert_equal :white, @kings_and_queens[:d1].side
        
  end
  
end
