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
	
	def test_longest_move_in_chess_is_8_units
		assert_equal 8, Chess.maximum_move_length
	end

	def test_piece_cannot_move_off_edge_of_board
		edge_pawn = Piece.new(:white, :pawn)
		edge_pawn.file, edge_pawn.rank  = 'a', '2'
		
		center_pawn = Piece.new(:white, :pawn)
		center_pawn.file, center_pawn.rank  = 'f', '2'
		
		assert_operator edge_pawn.theoretical_moves.length, :<, center_pawn.theoretical_moves.length
	end
	
	def test_knight_has_more_moves_in_the_center
		center_knight = Piece.new(:white, :queens_knight)
		center_knight.file, center_knight.rank = 'd', '4'
		assert_equal 'd4', center_knight.position
		
		assert_equal 8, center_knight.theoretical_moves.length, "In #{center_knight.theoretical_moves} #{center_knight.position}"
		assert center_knight.theoretical_moves.include?( 'e6' )
		
		corner_knight = Piece.new(:white, :kings_knight)
		corner_knight.file, corner_knight.rank = 'h', '8'
		
		
		assert_equal 2, corner_knight.theoretical_moves.length
		assert corner_knight.theoretical_moves.include?('g6')
		assert corner_knight.theoretical_moves.include?('f7')
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
