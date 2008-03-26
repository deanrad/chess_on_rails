require File.dirname(__FILE__) + '/../test_helper'

class PieceTest < ActiveSupport::TestCase
	# Replace this with your real tests.
	def test_truth
		assert true
	end
	
	def test_recognizes_valid_piece_types
		p = Piece.new(:white, :queens_knight)
		assert p.valid?
		
		p = Piece.new(:black, :pawn)
		assert p.valid?
		
	end
	
	def test_nodoc_remembers_position
		p = Piece.new(:white, :queens_knight)
		p.position = 'a2'
		
		assert_equal 'a', p.file
		assert_equal '2', p.rank
		assert_equal 'a2', p.position
		
	end
	#	def test_rejects_invalid_piece_types
	#		#for reason of piece
	#		p = Piece.new(:black, :mamas_jamas)
	#		assert !p.valid?
	#		assert_not_nil p.errors[:type]				
	#		
	#		#for reasons of color
	#		p = Piece.new(:mama, :pawn)
	#		assert !p.valid?
	#		assert_not_nil p.errors[:side]				
	#		
	#		#for both reasons 
	#		p = Piece.new(:mama, :jama)
	#		assert !p.valid?
	#		assert_not_nil p.errors[:type]				
	#		assert_not_nil p.errors[:side]				
	#		
	#		#because of lack of specificity
	#		p = Piece.new(:white, :rook)
	#		assert !p.valid?
	#		assert_not_nil p.errors[:type]			
	#	end
	
	def test_has_a_notation_for_king_and_queen
		assert_equal 'Q', Piece.new(:white, :queen).notation
		assert_equal 'K', Piece.new(:white, :king).notation
	end
	
	def test_has_a_notation_for_minor_and_rook
		p1 = Piece.new(:white, :queens_rook)
		p1.position = 'a1'
		assert_equal 'Ra', p1.notation
		
		p1 = Piece.new(:white, :queens_knight)
		p1.position = 'c3'
		assert_equal 'Nc', p1.notation
		
		#p1.file = nil
		#assert_equal 'N', p1.notation
	end
	
	def test_has_a_notation_for_pawn
		p1 = Piece.new(:black, :pawn)
		p1.position = 'b2'
		assert_equal 'b', p1.notation
	end
	
	def test_nodoc_can_set_get_position
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
		
		assert_equal 14, p.theoretical_moves.length, "#{p.theoretical_moves.to_s}"
		
	end
end
