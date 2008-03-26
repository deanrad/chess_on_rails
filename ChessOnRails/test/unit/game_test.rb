require File.dirname(__FILE__) + '/../test_helper'

class GameTest < ActiveSupport::TestCase
	# Replace this with your real tests.
	def test_truth
		assert true
	end
	def test_32_pieces_on_chess_initial_board
		assert_equal 32, Chess.initial_board.num_active_pieces
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
	
	def test_nodoc_lets_me_know_what_move_it_is
		assert true
	end
end
