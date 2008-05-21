require File.dirname(__FILE__) + '/../test_helper'

class MatchTest < ActiveSupport::TestCase

	def test_32_pieces_on_chess_initial_board
		assert_equal 32, matches(:unstarted_match).initial_board.num_active_pieces
	end
	def test_noone_to_move_defaults_to_player1
		m1 = matches(:dean_vs_maria)
		assert_equal 1, m1.next_to_move
	end

	#tests related to game play
	def test_next_to_move_alternates_sides
		m1 = matches(:unstarted_match)
		assert_equal 0, m1.moves.count
		assert_equal 1, m1.next_to_move
		
		m1.moves << Move.new(:from_coord=>"b2", :to_coord=>"c3", :moved_by=>1)
		
		assert_equal 2, m1.next_to_move
	end
			
	def test_knows_what_side_player_is_on
		m1 = matches(:paul_vs_dean)
		assert_equal players(:paul).id, m1.player1.id
		assert_equal players(:dean).id, m1.player2.id
		
		assert_equal :white, m1.side_of( players(:paul) )
		assert_equal :black, m1.side_of( players(:dean) )
		
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
		m1.save!
		assert_not_nil m1.winning_player
		assert_equal players(:dean), m1.winning_player

		#player2
		m2 = matches(:dean_vs_maria)
		m2.resign( m2.player2 )
		m2.save!

		m3 = matches(:dean_vs_maria)
		assert_not_nil m3.winning_player
		assert_equal players(:dean), m3.winning_player
	end

end
