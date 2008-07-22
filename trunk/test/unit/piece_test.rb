require File.dirname(__FILE__) + '/../test_helper'

class PieceTest < ActiveSupport::TestCase

  def test_recognize_valid_piece_types
    p = Piece.new(:white, :queens_knight)
    p = Piece.new(:black, :a_pawn)
  end
  
  def test_recognize_queen_vs_kings_bishop
    #three places in memory - are they the same under the == operator ?
    p1 = Piece.new(:white, :queens_knight)
    p2 = Piece.new(:black, :queens_knight)
    
    assert_not_nil p1
    assert_not_nil p2
    assert_not_equal p1.side, p2.side
    
    p3 = Piece.new(:white, :queens_bishop)
    p4 = Piece.new(:white, :kings_bishop)
    
    assert_not_equal p3.type, p4.type
  end
  
  def test_position_composed_of_rank_and_file
    p = Piece.new(:white, :queens_knight)
    p.position = 'a2'
    
    assert_equal 'a', p.file
    assert_equal '2', p.rank
    assert_equal 'a2', p.position
  end
  
  def test_has_a_notation_for_king_and_queen
    assert_equal 'Q', Piece.new(:white, :queen).notation
    assert_equal 'K', Piece.new(:white, :king).notation
  end
  
  def test_has_a_notation_for_minor_and_rook
    p1 = Piece.new(:white, :queens_rook)
    p1.position = 'a1'
    assert_equal 'R', p1.notation
    
    p1 = Piece.new(:white, :queens_knight)
    p1.position = 'c3'
    assert_equal 'N', p1.notation
    
    #p1.file = nil
    #assert_equal 'N', p1.notation
  end
  
  def test_has_a_notation_for_pawn
    p1 = Piece.new(:black, :b_pawn)
    p1.position = 'b2'
    assert_equal 'b', p1.notation
  end
    
  
  def test_rook_has_four_lines_of_attack
    p = Piece.new(:black, :queens_rook, 'a8')
    assert_equal 4, p.lines_of_attack.length
  end

  def test_bishop_has_four_lines_of_attack
    p = Piece.new(:white, :queens_bishop, 'c1')
    assert_equal 4, p.lines_of_attack.length
  end

  def test_queen_has_eight_lines_of_attack
    p = Piece.new(:white, :queen, 'h8')
    assert_equal 8, p.lines_of_attack.length
  end
  
  def test_kings_knights_pawns_have_no_lines_of_attack
    k = Piece.new(:white, :king, 'h8')
    n = Piece.new(:black, :knight, 'b2')
    p = Piece.new(:white, :pawn, 'd2')
    
    #the theoretical moves must be evaluated first before lines of attack can be known
    # (kind of backwards, yes, but)
    [k,n,p].each do |piece|
      ms = piece.theoretical_moves
      assert_equal 0, piece.lines_of_attack.length, "Piece #{piece.to_s} had lines of attack unexpectedly"
    end
    
  end

  def test_rook_can_move_nowhere_on_initial_board
    r = Piece.new(:black, :queens_rook, 'a8')
    b = matches(:unstarted_match).initial_board
    
    assert_equal 0,  r.allowed_moves( b ).length
  end

  def test_image_names_abstract_away_irrelevant_details
    assert_equal 'rook_b', Piece.new(:black, :queens_rook, 'a8').img_name
    assert_equal 'pawn_w', Piece.new(:white, :b_pawn, 'b2').img_name
  end	

  def test_nodoc_piece_is_promotable_to_queen_by_default
    p = Piece.new(:white, :b_pawn, 'c8')
    p.promote!

    assert_equal :queen.to_s, p.role
  end

  def test_pawn_may_not_promote_to_king
    p = Piece.new(:black, :c_pawn, 'c8')
    assert_raises ArgumentError do
      p.promote!( :king )
    end
  end

  def test_pawn_may_not_promote_unless_on_back_rank
    #black pawn must be on 1
    p = Piece.new(:black, :c_pawn, 'c8')
    assert_raises ArgumentError do
      p.promote!( :knight )
    end

    p.side, p.position = [:white, 'd7']
    assert_raises ArgumentError do
      p.promote!
    end
  end

  def test_nodoc_ascertains_promotability
    p = Piece.new(:black, :c_pawn, 'a8')
    assert ! p.promotable?
    assert Piece.new(:black, :f_pawn, 'a1').promotable?
  end
  def test_nodoc_board_id_indicates_promoted_piece
    p = Piece.new(:white, :a_pawn, 'b8')
    p.promote!
    assert_equal 'white_promoted_queen', p.board_id
  end

  def test_no_piece_other_than_pawn_may_promote
    p = Piece.new(:black, :queens_bishop, 'c8')
    assert_raises ArgumentError do
      p.promote!
    end
  end
end
