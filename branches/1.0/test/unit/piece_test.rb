require File.dirname(__FILE__) + '/../test_helper'

class PieceTest < ActiveSupport::TestCase

  def setup
    @k   = Piece.new( :king )
    @wb  = Piece.new( :bishop, :white )
    @bq  = Piece.new( :queen, :black )
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
  
  def test_needs_to_know_side_for_board_id
    assert_raises AmbiguousPieceError do
      puts @k.board_id
    end
  end
  
  def test_knows_board_id_given_sufficient_information
    assert_equal :black_queen, @bq.board_id
  end
end
