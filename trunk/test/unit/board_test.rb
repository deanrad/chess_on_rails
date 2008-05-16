require File.dirname(__FILE__) + '/../test_helper'

class BoardTest < ActiveSupport::TestCase
	# Replace this with your real tests.
	def test_truth
		assert true
	end
	
	def test_new_match_gets_an_initial_board
		m1 = matches(:unstarted_match)
		board = m1.initial_board
		
		assert_equal 32, board.num_active_pieces
		
		#havent enabled move replay just yet
		#assert_equal :current, board.as_of_move
	end
	
	def test_board_can_refer_to_move_number_or_refer_to_current_move
		m1 = matches(:unstarted_match)
		m1.moves << Move.new(:from_coord=>"d2", :to_coord=>"d4", :moved_by=>1, :notation=>"d4")
		m1.moves << Move.new(:from_coord=>"e7", :to_coord=>"e5", :moved_by=>2, :notation=>"e5")
		m1.save
		
		assert_not_nil m1.board(0)
		assert_not_nil m1.board(1)
		assert_not_nil m1.board(2)
		
		#doesnt yet - havent enabled replay ability yet
		#assert_raises ArgumentError do
		#	g = m1.board(3)
		#end
	end

	def test_knows_a_valid_location_and_distinguishes_between_invalid_one
		assert    Chess.valid_position?("a1")
		assert  ! Chess.valid_position?("n9")
		assert  ! Chess.valid_position?("a9")
		assert  ! Chess.valid_position?("1a")
	end
	
	def test_pawn_can_advance_one_or_two_on_first_move
		p = Piece.new(:white, :d_pawn)
		p.position = 'd2'
		moves = p.theoretical_moves

		['d3','d4'].each{ |loc| assert moves.include?(loc), "#{loc} not in list #{moves}"  }
		
		p = Piece.new(:black, :e_pawn)
		p.position = 'e7'
		moves = p.theoretical_moves
		['e6','e5'].each{ |loc| assert moves.include?(loc), "#{loc} not in list #{moves}"  }
	end
	
	def test_pawn_can_only_advance_one_on_successive_moves
		p = Piece.new(:white, :d_pawn)
		p.position='d4'
		moves = p.theoretical_moves
		assert !moves.include?('d6')
		
		p = Piece.new(:black, :e_pawn)
		p.position = 'e3'
		moves = p.theoretical_moves
		assert !moves.include?('e1')
	end
	
	def test_pawn_diagonal_captures_possible_accounting_for_ends
		p = Piece.new(:white, :d_pawn)
		p.position = 'd2'
		moves = p.theoretical_moves
		['e3','c3'].each{ |loc| assert moves.include?(loc), "#{loc} not in list #{moves}" }
		assert_equal 4, moves.length
		
		p = Piece.new(:black, :e_pawn)
		p.position='e7'
		moves = p.theoretical_moves
		['f6','d6'].each{ |loc| assert moves.include?(loc), "#{loc} not in list #{moves}"  }
		assert_equal 4, moves.length
	end
	
	def test_longest_move_in_chess_is_8_units
		assert_equal 8, Chess.maximum_move_length
	end
	
	def test_piece_cannot_move_off_edge_of_board
		edge_pawn = Piece.new(:white, :a_pawn)
		edge_pawn.position='a2'
		
		center_pawn = Piece.new(:white, :f_pawn)
		center_pawn.position='f2'
		
		assert_operator edge_pawn.theoretical_moves.length, :<, center_pawn.theoretical_moves.length
	end
	
	def test_knight_has_more_moves_in_the_center
		center_knight = Piece.new(:white, :queens_knight)
		center_knight.position ='d4'
		
		assert_equal 8, center_knight.theoretical_moves.length, "In #{center_knight.theoretical_moves} #{center_knight.position}"
		assert center_knight.theoretical_moves.include?( 'e6' )
		
		corner_knight = Piece.new(:white, :kings_knight)
		corner_knight.position = 'h8'
		
		
		assert_equal 2, corner_knight.theoretical_moves.length
		assert corner_knight.theoretical_moves.include?('g6')
		assert corner_knight.theoretical_moves.include?('f7')
	end
	
	def test_knows_what_side_occupies_a_square
		board = matches(:unstarted_match).initial_board
				
		assert_equal :white, board.side_occupying('a2')
		assert !board.position_occupied_by?( 'a2', :black )
		
		assert board.position_occupied_by?( 'e7', :black )
		assert !board.position_occupied_by?( 'e7', :white )
	end 

	# Replace this with your real tests.
	def test_truth
		assert true
	end
	
	def test_knows_what_piece_is_on_a_square
		assert_nil matches(:unstarted_match).initial_board.piece_at("d4")
		p1 = matches(:unstarted_match).initial_board.piece_at("b2")
		assert_not_nil p1
		
		assert_equal :b_pawn, p1.type
		assert_equal :white, p1.side
	end
	
	def test_can_refer_to_as_many_boards_as_there_are_moves
		match = matches(:unstarted_match)
		assert_not_nil match.initial_board
		
		#todo - get equality working at this level...
		#assert_equal match.initial_board, match.board(0)
		#assert_equal match.board(0), match.board #current board
		
		match.moves << Move.new( :from_coord=>"d2", :to_coord=>"d4", :notation=>"d4", :moved_by=>1 )
		match.save!

		#assert_not_equal match.board(0), match.board #current board
		#assert_equal match.board(1), match.board
				
		#assert_raises ArgumentError do
		#	b = match.board(2)	
		#end
		
	end
	
	def test_detects_moved_piece
		match = matches(:unstarted_match)
		assert_not_nil match.initial_board
		assert_equal 32, match.initial_board.num_active_pieces
		
		assert_nil match.initial_board.piece_at("d4")
		match.moves << Move.new( :from_coord=>"d2", :to_coord=>"d4", :notation=>"d4", :moved_by=>1 )
		match.save!
		
		#		#todo: this is the next test to pass after enabling board replay
		assert_not_nil match.board.piece_at("d4")
		
	end
			
end
