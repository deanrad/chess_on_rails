require File.dirname(__FILE__) + '/../spec_helper'

describe 'Piece' do

  def test_recognize_valid_piece_types
    p = Piece.new(:white, :queens_knight)
    p = Piece.new(:black, :a_pawn)
    #completes without error
  end
    
  def test_has_a_notation_for_king_and_queen
    assert_equal 'Q', Piece.new(:white, :queen).notation
    assert_equal 'K', Piece.new(:white, :king).notation
  end
  
  def test_has_a_notation_for_minor_and_rook
    p1 = Piece.new(:white, :queens_rook)
    assert_equal 'R', p1.notation
    
    p1 = Piece.new(:white, :queens_knight)
    assert_equal 'N', p1.notation
    
  end
  
  it 'should notate a pawn correctly' do
    p1 = Piece.new(:black, :b_pawn)
    #if still on file  b
    p1.notation.should == 'b'

    #if still on file c
    p1.notation('c').should == 'c'
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
    k = [ Piece.new(:white, :king), 'h8']
    n = [ Piece.new(:black, :knight), 'b2']
    p = [ Piece.new(:white, :pawn), 'd2']
    
    #the theoretical moves must be evaluated first before lines of attack can be known
    # (kind of backwards, yes, but)
    [k,n,p].each do |piece, position|
      moves = piece.theoretical_moves(position)
      assert_equal 0, piece.lines_of_attack.length, "Piece #{piece.to_s} had lines of attack unexpectedly"
    end
    
  end

  # this is not the style of test we want - its more of a sanity check
  def test_rook_can_move_nowhere_on_initial_board
    r = Piece.new(:black, :queens_rook)
    b = matches(:unstarted_match).board
    
    assert_equal 0,  r.allowed_moves( b, 'a8' ).length
  end

  def test_image_names_abstract_away_irrelevant_details
    assert_equal 'rook_b', Piece.new(:black, :queens_rook).img_name
    assert_equal 'pawn_w', Piece.new(:white, :b_pawn).img_name
  end	

  def test_nodoc_piece_is_promotable_to_queen_by_default
    p = Piece.new(:white, :b_pawn)
    p.promote!('8')

    assert_equal :queen.to_s, p.role
  end

  def test_pawn_may_not_promote_to_king
    p = Piece.new(:black, :c_pawn)
    assert_raises ArgumentError do
      p.promote!('8', :king )
    end
  end

  def test_pawn_may_not_promote_unless_on_back_rank
    #black pawn must be on 1
    p = Piece.new(:black, :c_pawn)
    assert_raises ArgumentError do
      p.promote!('8')
    end

    p.side = :white
    assert_raises ArgumentError do
      p.promote!('7')
    end
  end

  def test_nodoc_ascertains_promotability
    p = Piece.new(:black, :c_pawn)
    assert ! p.promotable?('8')
    assert Piece.new(:black, :f_pawn).promotable?('1')
  end
  
  def test_nodoc_board_id_indicates_promoted_piece
    p = Piece.new(:white, :a_pawn)
    p.promote!('8')
    assert_equal 'white_promoted_queen', p.board_id
  end

  def test_no_piece_other_than_pawn_may_promote
    p = Piece.new(:black, :queens_bishop)
    assert_raises ArgumentError do
      p.promote!('8')
    end
  end
    
end
