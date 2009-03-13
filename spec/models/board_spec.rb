require File.dirname(__FILE__) + '/../spec_helper'


#The board has the 
describe Board do

  # TODO - no fixtures
  fixtures :all
  
  def test_new_match_gets_an_initial_board
    m1 = matches(:unstarted_match)
    assert_equal 32, m1.board.pieces.length
  end
  
  def test_after_one_move_board_reflects_move
    m1 = matches(:unstarted_match)
    
    m1.moves << Move.new(:notation => 'e4')
    assert_not_nil m1.board['e4']
    
    #assert_not_equal b1, b2
    
  end
  
  def test_knows_a_valid_location_and_distinguishes_between_invalid_one
    assert    Chess.valid_position?('a1')
    assert  ! Chess.valid_position?('n9')
    assert  ! Chess.valid_position?('a9')
    assert  ! Chess.valid_position?('1a')
  end
  
  def test_pawn_can_advance_one_or_two_on_first_move
    p = Piece.new(:white, :d_pawn)
    moves = p.theoretical_moves('d2')

    ['d3','d4'].each{ |loc| assert moves.include?(loc), "#{loc} not in list #{moves}"  }
    
    p = Piece.new(:black, :e_pawn)
    moves = p.theoretical_moves( 'e7' )
    ['e6','e5'].each{ |loc| assert moves.include?(loc), "#{loc} not in list #{moves}"  }
  end
  
  def test_pawn_can_only_advance_one_on_successive_moves
    p = Piece.new(:white, :d_pawn)
    moves = p.theoretical_moves('d4')
    assert !moves.include?('d6')
    
    p = Piece.new(:black, :e_pawn)
    moves = p.theoretical_moves('e3')
    assert !moves.include?('e1')
  end
  
  def test_pawn_diagonal_captures_possible_accounting_for_ends
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
    
  def test_knows_what_side_occupies_a_square
    board = matches(:unstarted_match).board
        
    assert_equal :white, board['a2'].side
    assert_equal :black, board['e7'].side
  end 
  
  def test_knows_what_piece_is_on_a_square
    assert_nil matches(:unstarted_match).board['d4']
    p1 = matches(:unstarted_match).board['b2']
    assert_not_nil p1
    
    assert_equal 'pawn', p1.role
    assert_equal :white, p1.side
  end
  
  #def test_can_refer_to_as_many_boards_as_there_are_moves
  #  match = matches(:unstarted_match)
  #  assert_not_nil match.board
  #  
  #  match.moves << Move.new( :from_coord => 'd2', :to_coord => 'd4', :notation => 'd4' )
  #end
  
  def test_detects_moved_piece
    match = matches(:unstarted_match)
    assert_not_nil match.board
    
    assert_nil match.board['d4']
    match.moves << Move.new( :from_coord => 'd2', :to_coord => 'd4' )
    
    assert_not_nil match.board['d4']
  end

  def test_castled_short_white_king_on_g1
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
    match.board['b4'].allowed_moves(match.board, 'b4').should include('e1')

    assert_equal true, match.board.in_check?( :white ) 
  end

  def test_scholars_mate_capture_with_queen_is_checkmate
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

  def test_scholars_mate_capture_with_bishop_not_checkmate
    match = matches(:scholars_mate)
    match.moves << Move.new( :notation => 'Bxf7' )
    assert match.board.in_check?(:black)

    assert match.board['e8'].allowed_moves(match.board, 'e8').include?('e7')
    
    assert !match.board.in_checkmate?( :black ), "Black in checkmate unexpectedly"
  end

  def test_pawn_can_capture_en_passant
    match = matches(:unstarted_match)
    
    match.moves << Move.new(:notation => 'e4') 
    match.moves << Move.new(:notation => 'a5')
    match.moves << Move.new(:notation => 'e5')
    match.moves << Move.new(:notation => 'd5')
    
    board = match.board
    assert_not_nil board['e5'] #just moved there
    
    assert_equal ['e6','d6'], board['e5'].allowed_moves(board, 'e5')
    assert board.is_en_passant_capture?( 'e5', 'd6' )

    match.moves << Move.new(:from_coord => 'e5', :to_coord => 'd6')
    
    assert_equal 'd5', match.moves.last.captured_piece_coord
    assert_nil   match.board['d5'] 
  end	

  def test_pawn_en_passant_not_possible_for_single_stepped_opponent_pawn
    m = matches(:unstarted_match)
    m.moves << Move.new(:notation => 'e4') << Move.new(:notation => 'd6')
    m.moves << Move.new(:notation => 'e5') << Move.new(:notation => 'd5')

    b = m.board
    assert_equal ['e6'], b['e5'].allowed_moves(b, 'e5')
  end	

  def test_promotes_automatically_to_queen_on_reaching_opposing_back_rank
    m = matches(:promote_crazy)
    m.moves << Move.new( :from_coord => 'b7', :to_coord => 'a8' )

    assert_equal 'queen', m.board['a8'].role

    assert_equal 'bxa8=Q', m.moves.last.notation
  end

  def test_may_promote_to_knight_on_reaching_opposing_back_rank
    m = matches(:promote_crazy)
    #b = m.board
    m.moves << Move.new( :from_coord => 'b7', :to_coord => 'a8', :promotion_choice => 'N' )
    assert_equal 'bxa8=N', m.moves.last.notation
    assert_equal 'knight', m.board['a8'].role
  end

  # consider yields a copy of the board on which the move has occurred
  def test_considering_a_move_is_temporary
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

end
