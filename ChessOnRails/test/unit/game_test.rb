require File.dirname(__FILE__) + '/../test_helper'

class GameTest < ActiveSupport::TestCase
	# Replace this with your real tests.
	def test_truth
		assert true
	end
	def test_32_pieces_on_chess_initial_board
		assert_equal 32, Chess.initial_board.length
	end
	def test_noone_to_move_defaults_to_player1
		m1 = matches(:dean_vs_maria)
		assert_equal players(:dean), m1.next_to_move
	end
end
