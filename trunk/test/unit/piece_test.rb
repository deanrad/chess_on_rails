require File.dirname(__FILE__) + '/../test_helper'

class PieceTest < ActiveSupport::TestCase

	require 'Enumerable' 

	def test_nodoc_does_cartesian_product
		assert_equal [ [1,1], [1,2] ], [1].cartesian( [1,2] )
		assert_equal [ [1,3], [1,4], [2,3], [2,4] ], [1,2].cartesian( [3,4] )
	end

	def test_recognize_valid_piece_types
		p = Piece.new(:white, :queens_knight)
		p = Piece.new(:black, :a_pawn)
	end
	
	def test_recognize_queen_vs_kings_bishop
		#three places in memory - are they the same under the == operator ?
		p1 = Piece.new(:white, :queens_knight)
		p2 = Piece.new(:black, :queens_knight)
		
		assert_not_nil p1
		assert_not_nil p2
		assert_not_equal p1.side, p2.side
		
		p3 = Piece.new(:white, :queens_bishop)
		p4 = Piece.new(:white, :kings_bishop)
		
		assert_not_equal p3.type, p4.type
	end
	
	def test_position_composed_of_rank_and_file
		p = Piece.new(:white, :queens_knight)
		p.position = 'a2'
		
		assert_equal 'a', p.file
		assert_equal '2', p.rank
		assert_equal 'a2', p.position
	end
	
	def test_has_a_notation_for_king_and_queen
		assert_equal 'Q', Piece.new(:white, :queen).notation
		assert_equal 'K', Piece.new(:white, :king).notation
	end
	
	def test_has_a_notation_for_minor_and_rook
		p1 = Piece.new(:white, :queens_rook)
		p1.position = 'a1'
		assert_equal 'R', p1.notation
		
		p1 = Piece.new(:white, :queens_knight)
		p1.position = 'c3'
		assert_equal 'N', p1.notation
		
		#p1.file = nil
		#assert_equal 'N', p1.notation
	end
	
	def test_has_a_notation_for_pawn
		p1 = Piece.new(:black, :b_pawn)
		p1.position = 'b2'
		assert_equal 'b', p1.notation
	end
		
	def test_queen_moves_correctly
		p = Piece.new(:white, :queen)
		p.position= 'd4'
		
		assert p.theoretical_moves.include?('e5')
		assert p.theoretical_moves.include?('a1')
		assert p.theoretical_moves.include?('f2')
		assert p.theoretical_moves.include?('g1')
		assert p.theoretical_moves.include?('h8')
		assert !p.theoretical_moves.include?('e6')
	end
	
	def test_rook_moves_correctly
		p = Piece.new(:white, :kings_rook)
		p.position='d4'
		
		assert p.theoretical_moves.include?('e4')
		assert p.theoretical_moves.include?('c4')
		assert p.theoretical_moves.include?('d5')
		assert p.theoretical_moves.include?('d6')
		
		assert_equal 14, p.theoretical_moves.length, "Theoretical moves were #{p.theoretical_moves.to_s}"
	end
	
	def test_rook_has_four_lines_of_attack
		p = Piece.new(:black, :queens_rook, 'a8')
		assert_equal 14, p.theoretical_moves.length
		assert_equal 4, p.lines_of_attack.length
	end

	def test_bishop_has_four_lines_of_attack
		p = Piece.new(:white, :queens_bishop, 'c1')
		assert_equal 7, p.theoretical_moves.length
		assert_equal 4, p.lines_of_attack.length
	end

	def test_queen_has_eight_lines_of_attack
		p = Piece.new(:white, :queen, 'h8')
		assert_equal 21, p.theoretical_moves.length
		assert_equal 8, p.lines_of_attack.length
	end

	def test_kings_knights_pawns_have_no_lines_of_attack
		k = Piece.new(:white, :king, 'h8')
		n = Piece.new(:black, :knight, 'b2')
		p = Piece.new(:white, :pawn, 'd2')
		
		#the theoretical moves must be evaluated first before lines of attack can be known
		# (kind of backwards, yes, but)
		[k,n,p].each do |piece|
			ms = piece.theoretical_moves
			assert_equal 0, piece.lines_of_attack.length, "Piece #{piece.to_s} had lines of attack unexpectedly"
		end
		
	end

	def test_rook_can_move_nowhere_on_initial_board
		r = Piece.new(:black, :queens_rook, 'a8')
		b = matches(:unstarted_match).initial_board
		
		assert_equal 14, r.theoretical_moves.length
		assert_equal 0,  r.allowed_moves( b ).length
	end

	def test_queen_and_bishop_can_move_when_queens_pawn_moved
		#rewinds board to move 2
		b = matches(:dean_vs_paul).board(2)

		#the bishop
		bishop = b.piece_at('c1')
		assert_equal :queens_bishop, bishop.type
		assert_equal 5, bishop.allowed_moves(b).length

		#the queen
		queen = b.piece_at('d1')
		assert_equal :queen, queen.type
		assert_equal 2, queen.allowed_moves(b).length

	end

	def test_image_names_abstract_away_irrelevant_details
		assert_equal 'rook_b', Piece.new(:black, :queens_rook, 'a8').img_name
		assert_equal 'pawn_w', Piece.new(:white, :b_pawn, 'b2').img_name
	end	

	def test_pawn_can_capture_en_passant
		m = matches(:unstarted_match)
		m.moves << Move.new(:notation => 'e4') << Move.new(:notation => 'a5')
		m.moves << Move.new(:notation => 'e5') << Move.new(:notation => 'd5')

		b = m.board(:current)
		assert b.is_en_passant_capture?( 'e5', 'd6' )
		assert_equal ['e6','d6'], b.piece_at('e5').allowed_moves(b)

		m.moves << Move.new(:from_coord => 'e5', :to_coord => 'd6')
		
		assert_equal 'd5', m.moves.last.captured_piece_coord
		assert_nil m.board(:current).piece_at('d5') 
	end	

	def test_pawn_en_passant_not_possible_for_single_stepped_opponent_pawn
		m = matches(:unstarted_match)
		m.moves << Move.new(:notation => 'e4') << Move.new(:notation => 'd6')
		m.moves << Move.new(:notation => 'e5') << Move.new(:notation => 'd5')

		b = m.board(:current)
		assert_equal ['e6'], b.piece_at('e5').allowed_moves(b)
	end	
end
