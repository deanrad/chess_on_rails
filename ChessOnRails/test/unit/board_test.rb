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
	
	def test_pawn_can_advance_one_or_two_on_first_move
		p = Piece.new(:white, :pawn)
		p.file, p.rank = 'd', '2'
		moves = p.theoretical_moves
		['d3','d4'].each{ |loc| assert moves.include?(loc), "#{loc} not in list #{moves}"  }
		
		p = Piece.new(:black, :pawn)
		p.file, p.rank = 'e', '7'
		moves = p.theoretical_moves
		['e6','e5'].each{ |loc| assert moves.include?(loc), "#{loc} not in list #{moves}"  }
	end
	
	def test_pawn_can_only_advance_one_on_successive_moves
		p = Piece.new(:white, :pawn)
		p.file, p.rank = 'd', '4'
		moves = p.theoretical_moves
		assert !moves.include?('d6')
		
		p = Piece.new(:black, :pawn)
		p.file, p.rank = 'e', '3'
		moves = p.theoretical_moves
		assert !moves.include?('e1')
	end
	
	def test_pawn_diagonal_captures_possible_accounting_for_ends
		p = Piece.new(:white, :pawn)
		p.file, p.rank = 'd', '2'
		moves = p.theoretical_moves
		['e3','c3'].each{ |loc| assert moves.include?(loc), "#{loc} not in list #{moves}" }
		assert_equal 4, moves.length
		
		p = Piece.new(:black, :pawn)
		p.file, p.rank = 'e', '7'
		moves = p.theoretical_moves
		['f6','d6'].each{ |loc| assert moves.include?(loc), "#{loc} not in list #{moves}"  }
		assert_equal 4, moves.length
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
