require File.dirname(__FILE__) + '/../test_helper'

class BoardTest < ActiveSupport::TestCase
	# Replace this with your real tests.
	def test_truth
		assert true
	end
	
	def test_knows_a_valid_location_and_distinguishes_between_invalid_one
		assert    Chess.valid_position?("a1")
		assert  ! Chess.valid_position?("n9")
		assert  ! Chess.valid_position?("a9")
		assert  ! Chess.valid_position?("1a")
	end
	
	#one idea is that when board is returned, so are possible next moves
	def test_nodoc_can_get_possible_new_positions_for_piece
		assert true
	end
	def test_nodoc_can_put_new_move_and_get_board_back
		assert true
	end
	def test_nodoc_rejects_new_move_if_destination_occupied_by_piece_from_same_side
		assert true
	end
	def test_nodoc_rejects_new_move_if_beyond_range_of_board
		assert true
	end
	def test_nodoc_rejects_new_move_if_not_in_possible_moves_list
		assert true
	end
	def test_nodoc_rejects_new_move_if_places_own_king_in_check
		assert true
	end
end
