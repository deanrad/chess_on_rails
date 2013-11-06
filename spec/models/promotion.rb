require File.dirname(__FILE__) + '/../spec_helper'

describe 'Piece' do

  it 'should recognize_valid_piece_types' do
    p = Piece.new(:white, :queens_knight)
    p = Piece.new(:black, :a_pawn)
    #completes without error
  end
        
  it 'should image_names_abstract_away_irrelevant_details' do
    assert_equal 'rook_b', Rook.new(:black, :queens).img_name
    assert_equal 'pawn_w', Piece.new(:white, :pawn, :c).img_name
  end	

  it 'board_id should combine all fields' do
    Piece.new(:white, :pawn, :c).board_id.should == 'c_pawn_w'
    Rook.new(:black, :queens).board_id.should    == 'q_rook_b'
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
