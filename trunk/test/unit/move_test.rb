require File.dirname(__FILE__) + '/../test_helper'

class MoveTest < ActiveSupport::TestCase
		
	def test_unstarted_match_has_no_moves
		m1 = matches(:unstarted_match)
		assert_equal 0, m1.moves.count
	end
				
	def test_nodoc_can_play_first_two_moves_correctly
		m1 = matches(:unstarted_match)	  
		

		m1.moves << Move.new( :from_coord => 'e2', :to_coord => 'e4', :notation => 'e4', :moved_by => 1 )
		m1.moves << Move.new( :from_coord => 'd7', :to_coord => 'd5', :notation => 'd5', :moved_by => 2 )
		
		assert m1.valid?
		assert m1.save!
	end
	
	def test_notates_simple_move
		match = matches(:unstarted_match)
		move = Move.new( :match_id => match.id, :from_coord => 'b1', :to_coord => 'c3', :moved_by => 1 ) #knight opening
		assert_equal 'Nc3', move.notate
		match.moves << move
	end
	
	def test_notates_pawn_moves_correctly
		match = matches(:unstarted_match)
		move1 = Move.new( :match_id => match.id, :from_coord => 'd2', :to_coord => 'd4', :moved_by => 1 ) #queens pawn
		assert_equal 'd4', move1.notate
		match.moves << move1
	
		move2 = Move.new( :match_id => match.id, :from_coord => 'e7', :to_coord => 'e5', :moved_by => 2 ) 
		assert_equal 'e5', move2.notate
		match.moves << move2

		move3 = Move.new( :match_id => match.id, :from_coord => 'd4', :to_coord => 'e5', :moved_by => 1 ) 
		assert_equal 'dxe5', move3.notate
		match.moves << move3
	end

	def test_notates_white_kingside_castle_correctly
		match = matches(:dean_vs_maria)
		wc = Move.new( :match_id => match.id, :from_coord => 'e1', :to_coord => 'g1', :moved_by => 1 ) 
		assert_equal 'O-O', wc.notate
	end

	def test_does_not_notate_check_if_intervening_piece_blocks_check
		match = matches(:dean_vs_paul)
		ck = Move.new( :match_id => match.id, :from_coord => 'f1', :to_coord => 'b5' ) 
		assert_equal 'Bb5', ck.notate
	end

	def test_does_notate_check_if_no_intervening_piece_blocks_check
		match = matches(:dean_vs_paul)
		ck = Move.new( :match_id => match.id, :from_coord => 'f8', :to_coord => 'b4' ) 
		assert_equal 'Bb4+', ck.notate
	end
	
	def test_allows_move_from_notation_only
		match = matches(:dean_vs_paul)
		match.moves << Move.new( :notation => 'Bb5' )

		assert_equal 'f1', match.moves.last.from_coord
		assert_equal 'b5', match.moves.last.to_coord
	end

	def test_allows_move_from_notation_only_if_pawn
		match = matches(:dean_vs_paul)
		match.moves << Move.new( :notation => 'a4' )

		assert_equal 'a2', match.moves.last.from_coord
		assert_equal 'a4', match.moves.last.to_coord
	end

	def test_detects_attempt_to_move_from_incorrect_notation
		match = matches(:dean_vs_paul)

		assert_raises ArgumentError do
			match.moves << Move.new( :notation => 'Bb3' )
		end
	end
end
