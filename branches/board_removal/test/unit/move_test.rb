require File.dirname(__FILE__) + '/../test_helper'

class MoveTest < ActiveSupport::TestCase
    
  def test_unstarted_match_has_no_moves
    match = matches(:unstarted_match)
    assert_equal 0, match.moves.count
  end
        
  def test_notates_noncapturing_knight_move
    match = matches(:unstarted_match)
    match.moves << Move.new( :from_coord => 'b1', :to_coord => 'c3' ) 
    assert_equal 'Nc3', match.moves.last.notation
  end

  def test_pawn_cannot_move_two_initially_if_blocked
    match = matches(:unstarted_match)
    board = match.board 
    
    assert_not_nil board.pieces
    assert_not_nil board.piece_at('d2')
    
    assert_equal ['d3', 'd4'], board.piece_at('d2').allowed_moves(board)

    #now move the knight to block the d-pawn
    board.piece_at('b8').position = 'd3' 

    assert_equal [], board.piece_at('d2').allowed_moves( board )
  end
  
  def test_notates_noncapturing_pawn_moves_correctly
    match = matches(:unstarted_match)
    match.moves << Move.new( :from_coord => 'd2', :to_coord => 'd4' ) #queens pawn
    assert_equal 'd4', match.moves.last.notation
  
    match.moves << Move.new( :from_coord => 'e7', :to_coord => 'e5' ) 
    assert_equal 'e5', match.moves.last.notation

    match.moves << Move.new( :from_coord => 'd4', :to_coord => 'e5' ) 
    assert_equal 'dxe5', match.moves.last.notation
  end

  def test_notates_white_kingside_castle_correctly
    match = matches(:dean_vs_maria)
    match.moves << Move.new( :from_coord => 'e1', :to_coord => 'g1' ) 

    assert_equal 1, match.moves.last.castled
    assert_equal 'O-O', match.moves.last.notation

  end

  def test_notates_white_queenside_castle_correctly
    match = matches(:queenside_castled)
    match.moves << Move.new( :from_coord => 'e1', :to_coord => 'c1' ) 
    assert_equal 1, match.moves.last.castled
    assert_equal 'O-O-O', match.moves.last.notation
  end

  def test_notates_check_if_no_intervening_piece_blocks_check
    match = matches(:dean_vs_paul)
    match.moves << Move.new( :from_coord => 'f8', :to_coord => 'b4' ) 
    assert_equal 'Bb4+', match.moves.last.notation
  end

  def test_does_not_notate_check_if_intervening_piece_blocks_check
    match = matches(:dean_vs_paul)
    match.moves << Move.new( :from_coord => 'f1', :to_coord => 'b5' ) 
    assert_equal 'Bb5', match.moves.last.notation
  end
  
  def test_allows_move_from_notation_only
    match = matches(:dean_vs_paul)
    
    match.moves << Move.new( :notation => 'Bb5' )

    assert_equal 'f1', match.moves.last.from_coord
    assert_equal 'b5', match.moves.last.to_coord
  end

  def test_allows_move_from_notation_only_pawn_version
    match = matches(:dean_vs_paul)
    match.moves << Move.new( :notation => 'a4' )

    assert_equal 'a2', match.moves.last.from_coord
    assert_equal 'a4', match.moves.last.to_coord
  end

  def test_detects_attempt_to_move_from_incorrect_notation
    match = matches(:dean_vs_paul)

    #models can raise errors, controllers ultimately should not
    assert_raises ActiveRecord::RecordInvalid do
      match.moves.build( :notation => 'Bb3' ).save!
    end
  end
  
  def test_notates_which_knight_moved_to_a_square_if_ambiguous
    match = matches(:queenside_castled)

    #there are two knights which could have moved here - did we show which one
    match.moves << Move.new( :from_coord => 'g1', :to_coord => 'f3' )
    assert_equal 'Ngf3', match.moves.last.notation
  end

  #def test_disambiguates_knight_move_in_coordinates_when_moved_by_notation
  #	match = matches(:queenside_castled)
  #
  #	move = match.moves.build( :notation => 'Ngf3' )
  #	move.save!
  #	assert_equal 'g1', match.moves.last.from_coord
  #end

  def test_can_castle_via_notation
    match = matches(:dean_vs_maria)
    move = match.moves << Move.new( :notation => 'O-O' )
    assert_equal 1, match.moves.last.castled
    assert_equal 'g1', match.moves.last.to_coord
  end

  def test_errs_if_unrecognized_notation
    match = matches(:dean_vs_maria)
    move = match.moves.build( :notation => 'move it baby' )
    assert_raises ActiveRecord::RecordInvalid do
      move.save!
    end
  end
  
  def test_errs_if_ambiguous_move_made_by_notation

    match = matches(:queenside_castled)
    assert_raises ActiveRecord::RecordInvalid do
      move = match.moves.build( :notation => 'Nf3' )
      move.save!
    end
  end

=begin
  def test_errs_if_move_leaves_ones_own_king_in_check

    match = matches(:scholars_mate)

    #this is not a mating move but king is in check and must move
    match.moves << Move.new( :notation => 'Bxf7' )

    assert_raises ActiveRecord::RecordInvalid do
      move = match.moves.build( :notation => 'Nf6' )
      move.save!
    end
  end
=end

end
