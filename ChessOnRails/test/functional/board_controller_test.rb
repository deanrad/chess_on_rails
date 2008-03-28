require File.dirname(__FILE__) + '/../test_helper'

class BoardControllerTest < ActionController::TestCase
	# Replace this with your real tests.
	def test_truth
		assert true
	end

	#should be functional test
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
