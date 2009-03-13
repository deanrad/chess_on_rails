require File.dirname(__FILE__) + '/../spec_helper'

describe 'Piece' do

  it 'should recognize_valid_piece_types' do
    p = Piece.new(:white, :queens_knight)
    p = Piece.new(:black, :a_pawn)
    #completes without error
  end
        
  it 'should rook_has_four_lines_of_attack' do
    p = Piece.new(:black, :queens_rook, 'a8')
    assert_equal 4, p.lines_of_attack.length
  end

  it 'should bishop_has_four_lines_of_attack' do
    p = Piece.new(:white, :queens_bishop, 'c1')
    assert_equal 4, p.lines_of_attack.length
  end

  it 'should queen_has_eight_lines_of_attack' do
    p = Piece.new(:white, :queen, 'h8')
    assert_equal 8, p.lines_of_attack.length
  end
  
  it 'should kings_knights_pawns_have_no_lines_of_attack' do
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
  it 'should rook_can_move_nowhere_on_initial_board' do
    r = Piece.new(:black, :queens_rook)
    b = matches(:unstarted_match).board
    
    assert_equal 0,  r.allowed_moves( b, 'a8' ).length
  end

  it 'should image_names_abstract_away_irrelevant_details' do
    assert_equal 'rook_b', Piece.new(:black, :queens_rook).img_name
    assert_equal 'pawn_w', Piece.new(:white, :b_pawn).img_name
  end	

  it 'should nodoc_piece_is_promotable_to_queen_by_default' do
    p = Piece.new(:white, :b_pawn)
    p.promote!('8')

    assert_equal :queen.to_s, p.role
  end

  it 'should pawn_may_not_promote_to_king' do
    p = Piece.new(:black, :c_pawn)
    assert_raises ArgumentError do
      p.promote!('8', :king )
    end
  end

  it 'should pawn_may_not_promote_unless_on_back_rank' do
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

  it 'should nodoc_ascertains_promotability' do
    p = Piece.new(:black, :c_pawn)
    assert ! p.promotable?('8')
    assert Piece.new(:black, :f_pawn).promotable?('1')
  end
  
  it 'should nodoc_board_id_indicates_promoted_piece' do
    p = Piece.new(:white, :a_pawn)
    p.promote!('8')
    assert_equal 'white_promoted_queen', p.board_id
  end

  it 'should no_piece_other_than_pawn_may_promote' do
    p = Piece.new(:black, :queens_bishop)
    assert_raises ArgumentError do
      p.promote!('8')
    end
  end
    
end
