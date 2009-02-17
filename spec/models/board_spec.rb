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
  
  #def test_board_can_refer_to_move_number_or_refer_to_current_move
  #  m1 = matches(:unstarted_match)
  #  m1.moves << Move.new(:from_coord=>'d2', :to_coord=>'d4', :moved_by=>1, :notation=>'d4')
  #  m1.moves << Move.new(:from_coord=>'e7', :to_coord=>'e5', :moved_by=>2, :notation=>'e5')
  #  m1.save
  #  
  #  assert_not_nil m1.board(0)
  #  assert_not_nil m1.board(1)
  #  assert_not_nil m1.board(2)
  #end

  def test_knows_a_valid_location_and_distinguishes_between_invalid_one
    assert    Chess.valid_position?('a1')
    assert  ! Chess.valid_position?('n9')
    assert  ! Chess.valid_position?('a9')
    assert  ! Chess.valid_position?('1a')
  end
  
  def test_pawn_can_advance_one_or_two_on_first_move
    p = Piece.new(:white, :d_pawn)
    p.position = 'd2'
    moves = p.theoretical_moves

    ['d3','d4'].each{ |loc| assert moves.include?(loc), "#{loc} not in list #{moves}"  }
    
    p = Piece.new(:black, :e_pawn)
    p.position = 'e7'
    moves = p.theoretical_moves
    ['e6','e5'].each{ |loc| assert moves.include?(loc), "#{loc} not in list #{moves}"  }
  end
  
  def test_pawn_can_only_advance_one_on_successive_moves
    p = Piece.new(:white, :d_pawn)
    p.position='d4'
    moves = p.theoretical_moves
    assert !moves.include?('d6')
    
    p = Piece.new(:black, :e_pawn)
    p.position = 'e3'
    moves = p.theoretical_moves
    assert !moves.include?('e1')
  end
  
  def test_pawn_diagonal_captures_possible_accounting_for_ends
    p = Piece.new(:white, :d_pawn)
    p.position = 'd2'
    moves = p.theoretical_moves
    ['e3','c3'].each{ |loc| assert moves.include?(loc), "#{loc} not in list #{moves}" }
    assert_equal 4, moves.length
    
    p = Piece.new(:black, :e_pawn)
    p.position='e7'
    moves = p.theoretical_moves
    ['f6','d6'].each{ |loc| assert moves.include?(loc), "#{loc} not in list #{moves}"  }
    assert_equal 4, moves.length
  end
    
  def test_piece_cannot_move_off_edge_of_board
    edge_pawn = Piece.new(:white, :a_pawn)
    edge_pawn.position='a2'
    
    center_pawn = Piece.new(:white, :f_pawn)
    center_pawn.position='f2'
    
    assert_operator edge_pawn.theoretical_moves.length, :<, center_pawn.theoretical_moves.length
  end
  
  def test_knight_has_more_moves_in_the_center
    center_knight = Piece.new(:white, :queens_knight)
    center_knight.position ='d4'
    
    assert_equal 8, center_knight.theoretical_moves.length, "In #{center_knight.theoretical_moves} #{center_knight.position}"
    assert center_knight.theoretical_moves.include?( 'e6' )
    
    corner_knight = Piece.new(:white, :kings_knight)
    corner_knight.position = 'h8'
    
    
    assert_equal 2, corner_knight.theoretical_moves.length
    assert corner_knight.theoretical_moves.include?('g6')
    assert corner_knight.theoretical_moves.include?('f7')
  end
  
  def test_knows_what_side_occupies_a_square
    board = matches(:unstarted_match).board
        
    assert_equal :white, board['a2'].side
    assert_equal :black, board['e7'].side
  end 
  
  def test_knows_what_piece_is_on_a_square
    assert_nil matches(:unstarted_match).board.piece_at('d4')
    p1 = matches(:unstarted_match).board.piece_at('b2')
    assert_not_nil p1
    
    assert_equal 'pawn', p1.role
    assert_equal :white, p1.side
  end
  
  #def test_can_refer_to_as_many_boards_as_there_are_moves
  #  match = matches(:unstarted_match)
  #  assert_not_nil match.board
  #  
  #  match.moves << Move.new( :from_coord=>'d2', :to_coord=>'d4', :notation=>'d4' )
  #end
  
  def test_detects_moved_piece
    match = matches(:unstarted_match)
    assert_not_nil match.board
    
    assert_nil match.board.piece_at('d4')
    match.moves << Move.new( :from_coord=>'d2', :to_coord=>'d4', :notation=>'d4' )
    
    assert_not_nil match.board.piece_at('d4')
  end

  def test_castled_short_white_king_on_g1
    match = matches(:castled)

    piece = match.board.piece_at('g1')
    assert_not_nil piece
    assert_equal :king, piece.type

    piece = match.board['f1']
    assert_not_nil piece
    assert_equal :kings_rook, piece.type

  end

  #def test_can_refer_to_previous_board_with_negative_index
  #  match = matches(:castled)
  #
    #the king is on the square he started on
  #  piece = match.board(-1).piece_at('e1')
  #  assert_not_nil piece
  #  assert_equal :king, piece.type

    #other pieces are moved
  #  assert_nil match.board(-1).piece_at('f1')
  #end

  def test_knows_if_side_is_in_check
    match = matches(:dean_vs_paul)
    ck = Move.new( :match_id => match.id, :from_coord => 'f8', :to_coord => 'b4' ) 
    assert_equal 'Bb4+', ck.notate
    
    match.moves << ck
    assert_equal true, match.board.in_check?( :white ) #nope
  end

  def test_scholars_mate_capture_with_queen_is_checkmate
    match = matches(:scholars_mate)
    assert_equal :white, match.next_to_move
    assert_equal 'queen', match.board.piece_at('f3').role

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

    assert match.board.piece_at('e8').allowed_moves(match.board).include?('e7')
    
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
    
    assert_equal ['e6','d6'], board.piece_at('e5').allowed_moves(board)
    assert board.is_en_passant_capture?( 'e5', 'd6' )

    match.moves << Move.new(:from_coord => 'e5', :to_coord => 'd6')
    
    assert_equal 'd5', match.moves.last.captured_piece_coord
    assert_nil   match.board.piece_at('d5') 
  end	

  def test_pawn_en_passant_not_possible_for_single_stepped_opponent_pawn
    m = matches(:unstarted_match)
    m.moves << Move.new(:notation => 'e4') << Move.new(:notation => 'd6')
    m.moves << Move.new(:notation => 'e5') << Move.new(:notation => 'd5')

    b = m.board
    assert_equal ['e6'], b.piece_at('e5').allowed_moves(b)
  end	

  def test_promotes_automatically_to_queen_on_reaching_opposing_back_rank
    m = matches(:promote_crazy)
    m.moves << Move.new( :from_coord => 'b7', :to_coord => 'a8' )

    assert_equal 'queen', m.board.piece_at('a8').role

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
