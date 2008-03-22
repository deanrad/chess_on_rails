require File.dirname(__FILE__) + '/../test_helper'

class GameTest < ActiveSupport::TestCase
	# Replace this with your real tests.
	def test_truth
		assert true
	end
	def test_initial_pieces_in_chess_numbers
		assert_equal 32, Chess.initial_pieces.length
	end
	def test_noone_to_move_defaults_to_player1
		m1 = matches(:dean_vs_maria)
		assert_equal players(:dean), m1.next_to_move
	end
end
