require File.dirname(__FILE__) + '/../spec_helper'


#The board has the 
describe Board do
  
  it 'should new_match_gets_an_initial_board' do
    m1 = matches(:unstarted_match)
    assert_equal 32, m1.board.pieces.length
  end
  
  it 'should after_one_move_board_reflects_move' do
    m1 = matches(:unstarted_match)
    
    m1.moves << Move.new(:notation => 'e4')
    assert_not_nil m1.board['e4']
    
    #assert_not_equal b1, b2
    
  end
  
  it 'should knows_a_valid_location_and_distinguishes_between_invalid_one' do
    assert    Chess.valid_position?('a1')
    assert  ! Chess.valid_position?('n9')
    assert  ! Chess.valid_position?('a9')
    assert  ! Chess.valid_position?('1a')
  end
  
  it 'a pawn on its home square can move one or two' do
    match = matches(:unstarted_match)
    board = match.board

    pawn = board[:d2] #TODO we must do away with string access
    Pawn.should === pawn
    pawn.allowed_move?([0,1], 2).should == true
    pawn.allowed_move?([0,2], 2).should == true

    pawn.allowed_moves(board).should == [:d3, :d4]
  end

  it 'a bishop can not move if it is obstructed' do
    match = matches(:unstarted_match)
    board = match.board
    bishop = board[:c1]
    bishop.allowed_moves(board).should == []
  end  

  it 'should pawn_can_only_advance_one_on_successive_moves' do
    p = Piece.new(:white, :d_pawn)
    moves = p.theoretical_moves('d4')
    assert !moves.include?('d6')
    
    p = Piece.new(:black, :e_pawn)
    moves = p.theoretical_moves('e3')
    assert !moves.include?('e1')
  end
  
  it 'should pawn_diagonal_captures_possible_accounting_for_ends' do
    p = Piece.new(:white, :d_pawn)
    moves = p.theoretical_moves 'd2'
    ['e3','c3'].each{ |loc| assert moves.include?(loc), "#{loc} not in list #{moves}" }
    assert_equal 4, moves.length
    
    p = Piece.new(:black, :e_pawn)
    moves = p.theoretical_moves 'e7'
    ['f6','d6'].each{ |loc| assert moves.include?(loc), "#{loc} not in list #{moves}"  }
    assert_equal 4, moves.length
  end
    
  it 'has fewer moves at edge of board than in center' do
    edge_pawn = Piece.new(:white, :a_pawn)
    
    center_pawn = Piece.new(:white, :f_pawn)
    
    edge_pawn.theoretical_moves('a2').length.should <= center_pawn.theoretical_moves('f2').length
  end
    
  it 'should knows_what_side_occupies_a_square' do
    board = matches(:unstarted_match).board
        
    assert_equal :white, board['a2'].side
    assert_equal :black, board['e7'].side
  end 
  
  it 'should knows_what_piece_is_on_a_square' do
    assert_nil matches(:unstarted_match).board['d4']
    p1 = matches(:unstarted_match).board['b2']
    assert_not_nil p1
    
    assert_equal 'pawn', p1.role
    assert_equal :white, p1.side
  end
    
  it 'should detects_moved_piece' do
    match = matches(:unstarted_match)
    assert_not_nil match.board
    
    assert_nil match.board['d4']
    match.moves << Move.new( :from_coord => 'd2', :to_coord => 'd4' )
    
    assert_not_nil match.board['d4']
  end

  it 'should castled_short_white_king_on_g1' do
    match = matches(:castled)

    piece = match.board['g1']
    assert_not_nil piece
    assert_equal :king, piece.type

    piece = match.board['f1']
    assert_not_nil piece
    assert_equal :kings_rook, piece.type

  end

  it "knows when king is in check" do
    match = matches(:dean_vs_paul)
    ck = Move.new( :match_id => match.id, :from_coord => 'f8', :to_coord => 'b4' ) 
    #assert_equal 'Bb4+', ck.notate
    
    match.moves << ck
    match.board['b4'].allowed_moves(match.board).should include('e1')

    assert_equal true, match.board.in_check?( :white ) 
  end

  it 'should scholars_mate_capture_with_queen_is_checkmate' do
    match = matches(:scholars_mate)
    assert_equal :white, match.next_to_move
    assert_equal 'queen', match.board['f3'].role

    #make the killer move    
    match.moves << Move.new( :notation => 'Qf7' )

    #king is in check
    assert match.board.in_check?(:black)

    # and it's over !!
    assert match.board.in_checkmate?(:black), "Not in checkmate as expected"
  end

  it 'should scholars_mate_capture_with_bishop_not_checkmate' do
    match = matches(:scholars_mate)
    match.moves << Move.new( :notation => 'Bxf7' )
    assert match.board.in_check?(:black)

    assert match.board['e8'].allowed_moves(match.board).include?('e7')
    
    assert !match.board.in_checkmate?( :black ), "Black in checkmate unexpectedly"
  end

  it 'should pawn_can_capture_en_passant' do
    match = matches(:unstarted_match)
    
    match.moves << Move.new(:notation => 'e4') 
    match.moves << Move.new(:notation => 'a5')
    match.moves << Move.new(:notation => 'e5')
    match.moves << Move.new(:notation => 'd5')
    
    board = match.board
    assert_not_nil board['e5'] #just moved there
    
    assert_equal ['e6','d6'], board['e5'].allowed_moves(board)
    assert board.is_en_passant_capture?( 'e5', 'd6' )

    match.moves << Move.new(:from_coord => 'e5', :to_coord => 'd6')
    
    assert_equal 'd5', match.moves.last.captured_piece_coord
    assert_nil   match.board['d5'] 
  end	

  it 'should pawn_en_passant_not_possible_for_single_stepped_opponent_pawn' do
    m = matches(:unstarted_match)
    m.moves << Move.new(:notation => 'e4') << Move.new(:notation => 'd6')
    m.moves << Move.new(:notation => 'e5') << Move.new(:notation => 'd5')

    b = m.board
    assert_equal ['e6'], b['e5'].allowed_moves(b)
  end	

  #LEFTOFF restoring promotion
  it 'should promotes_automatically_to_queen_on_reaching_opposing_back_rank' do
    m = matches(:promote_crazy)
    m.moves << Move.new( :from_coord => 'b7', :to_coord => 'a8' )

    m.board[:a8].function.should == :queen

    m.moves.last.notation.should == 'bxa8=Q'
  end

  it 'should may_promote_to_knight_on_reaching_opposing_back_rank' do
    m = matches(:promote_crazy)
    #b = m.board
    m.moves << Move.new( :from_coord => 'b7', :to_coord => 'a8', :promotion_choice => 'N' )
    assert_equal 'bxa8=N', m.moves.last.notation
    assert_equal 'knight', m.board['a8'].role
  end

  # consider yields a copy of the board on which the move has occurred
  it 'should considering_a_move_is_temporary' do
    match = matches(:unstarted_match)
    board = match.board
    assert_equal :white, board['a2'].side
    assert_equal :black, board['e7'].side
    
    board.consider_move( Move.new( :from_coord => 'a2', :to_coord => 'a4'  ) ) do |new_board|
      assert_nil      new_board['a2']
      assert_not_nil  new_board['a4']
    end

    assert_not_nil    board['a2']
    assert_nil        board['a4']    
  end 

  it 'can output board in string format' do
    match = matches(:unstarted_match)
    board = match.board
    board.to_s.should == <<-DaBoard
r n b q k b n r
p p p p p p p p
               
               
               
               
P P P P P P P P
R N B Q K B N R

DaBoard
  end
end
