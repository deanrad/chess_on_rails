require File.dirname(__FILE__) + '/../test_helper'
class MatchTest < ActiveSupport::TestCase

  require 'ruby-debug'

  def test_newly_minted_match_has_live_pieces
      m = Match.new( :player1 => players(:dean), :player2 => players(:chris)  )
      m.save!
      assert_not_nil m.pieces
      assert_not_nil m.pieces[0]
  end
  
  def test_pieces_are_updated_when_you_move

      # also works with m = matches(:unstarted_match)
      m = Match.new( :player1 => players(:dean), :player2 => players(:chris)  )
      m.save!
      m.moves << Move.new( :notation => 'e4' )
      assert_not_nil m.pieces.find{ |p| p.position == 'e4'}
      assert_nil     m.pieces.find{ |p| p.position == 'e2'}

      m.moves << Move.new( :notation => 'd5' )
      assert_not_nil m.pieces.find{ |p| p.position == 'd5'}
      assert_nil     m.pieces.find{ |p| p.position == 'd7'}
      assert_equal   'd7', m.moves.last.from_coord
  end  

  def test_32_pieces_on_chess_initial_board
    assert_equal 32, matches(:unstarted_match).board.pieces.length
  end

  def test_first_player_to_move_is_player1
    m1 = matches(:unstarted_match)
    assert_equal 0, m1.moves.length
    assert m1.turn_of?( m1.player1)
  end

  #tests related to game play
  def test_next_to_move_alternates_sides
    m1 = matches(:unstarted_match)
    assert_equal 0, m1.moves.count
    assert m1.turn_of?( m1.player1 )
    
    m1.moves << Move.new(:from_coord=>'b2', :to_coord=>'b4' )
    
    assert m1.turn_of?( m1.player2 )

  end
      
  def test_knows_what_side_player_is_on
    m1 = matches(:paul_vs_dean)
    assert_equal players(:paul).id, m1.player1.id
    assert_equal players(:dean).id, m1.player2.id
    
    assert_equal :white, m1.side_of( players(:paul) )
    assert_equal :black, m1.side_of( players(:dean) )
    assert_equal :white, m1.opposite_side_of( players(:dean) )		
  end

  def test_knows_whose_turn_it_is
    m1 = matches(:paul_vs_dean)
    assert_equal 0, m1.moves.count

    assert m1.turn_of?( players(:paul) )
  end

  def test_shows_lineup
    assert_equal 'Paul vs. Dean', matches(:paul_vs_dean).lineup
    assert_equal 'Dean vs. Paul', matches(:dean_vs_paul).lineup
  end

  def test_player_can_resign
    #player1
    m1 = matches(:paul_vs_dean)
    m1.resign( players(:paul) )
    assert_not_nil m1.winning_player
    assert_equal players(:dean), m1.winning_player
  end

   #begin section that were formerly 'board' tests
   def test_considering_a_move_is_non_destructive_to_the_board_nodoc
      m = matches(:unstarted_match)
      board = m.board

      assert_not_nil     m.board.piece_at('a2')
      assert_nil         m.board.piece_at('a4')
      
      m.consider_move( Move.new( :from_coord => 'a2', :to_coord => 'a4') ) do
         assert_nil      m.board.piece_at('a2')
         assert_not_nil  m.board.piece_at('a4')
         assert_equal    'pawn', m.board.piece_at('a4').role
      end

      assert_not_nil     m.board.piece_at('a2')
      assert_nil         m.board.piece_at('a4')
   end
  
  def test_subset_works_as_in_math
    assert_equal true,  subset_of?( [1,2], [1,2,3,4] )
    assert_equal false, subset_of?( [1,2], [2,3]     )
    assert_equal false, subset_of?( [1,2,3], [1,2]     )

    assert_equal true, subset_of?( ['1'], ['1','2']     )

    assert_equal true, subset_of?( ['1'], ['1'.to_i.to_s,'2']     )

    #does not work for pieces !
    p = Piece.new(:white, :a_pawn, 'a2')
    p2 = p.clone
    assert_equal true, subset_of?( [p], [p]   )
    assert_equal true, subset_of?( [p], [p2]   )

  end
  
  def test_im_not_crazy
    assert_equal Chess.initial_pieces, Chess.initial_pieces, "Chess.initial_pieces equal to itself"
    assert_equal 32, Chess.initial_pieces.length, "Chess.initial_pieces count is 32"
  
    match=matches(:unstarted_match)
    assert_equal 32, match.board.pieces.length, "match.board.pieces.length is 32"
    assert subset_of?( Chess.initial_pieces, match.board.pieces )
    
    assert_equal match.board.pieces, match.board.pieces
    assert_equal match.board.pieces[0].object_id, match.board.pieces[0].object_id

    #clone makes a SHALLOW copy
    clone_of_pieces = match.board.pieces.clone
    assert_not_equal match.board.pieces.object_id, clone_of_pieces.object_id
    assert_equal match.board.pieces[0].object_id, clone_of_pieces[0].object_id
    
    #Marshal makes a DEEP copy - it makes a copy of the object (serialization) 
    # and brings that back as though under a new identity
    reload_of_pieces = Marshal.load( Marshal.dump(match.board.pieces) )
    assert_not_equal match.board.pieces.object_id, reload_of_pieces.object_id
    assert_not_equal match.board.pieces[0].object_id, reload_of_pieces[0].object_id
    assert_equal match.board.pieces[0].position, reload_of_pieces[0].position

    #change something like piece position directly through an accessor

    match.board.pieces[0].position = 'a4'
    assert_equal 'a4', match.board.pieces[0].position
    assert_equal 'a4', match.board.pieces[0].position
    assert_equal 'a2', reload_of_pieces[0].position

    # Now we've 'undone' the move of the pawn to a4
    match.pieces = reload_of_pieces
    assert_equal 'a2', match.board.pieces[0].position
    assert_equal 'a2', match.pieces[0].position
    assert_equal 'a2', match.board.pieces[0].position
    assert_not_nil match.board.piece_at('a2')
    assert_equal match.pieces[0], match.board.piece_at('a2')

    
    #now start over by making a move 
    match.board.play_move!( Move.new(:from_coord => 'a2', :to_coord => 'a4' ) )  
    assert_equal 'a2', reload_of_pieces[0].position, "Uhoh, moving piece on match.board affected variable reload_of_pieces as unintended side effect"
    
    assert_not_equal 'a2', match.board.pieces[0].position
    assert_not_nil match.board.piece_at('a4')
    
    debugger
    match.pieces = reload_of_pieces
    assert_equal 'a2', match.board.pieces[0].position, "Doing a reload_of_pieces does not help in the play_move! case"
    #and we dont care what happened to reload_of_pieces, we just made a copy of the 
    # entire piece array (relatively cheap)

  end
  
  private
  
  #Set 'one' is a subset of set 'other' only if each of one is a member of the other
  def subset_of?( one, other )
    one.each do |item|
      found_in_other = other.inject(false){ |is_present, other_item| is_present or item==other_item or ( item.respond_to?('equals') and item.equals(other_item) ) }
      return false unless found_in_other
    end
    true
  end
  
end

  
