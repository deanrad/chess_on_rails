#A Board is a snapshot of a match at a moment in time.
class Board

	attr_accessor :match
	attr_accessor :pieces
	attr_accessor :as_of_move
	
	#todo remove need for pieces
	def initialize(match, pieces, as_of_move)
		
		#initialize from the game's initial board, but replay moves...
		@pieces = pieces
		@match = match
		
		#figure out the number of moves we're replaying to
		if (as_of_move==:current)
			@as_of_move = @match.moves.count
		elsif  as_of_move.to_i < 0
			@as_of_move = @match.moves.count + as_of_move.to_i
		else
			@as_of_move = as_of_move.to_i
		end
		
		@match.moves[0..@as_of_move-1].each do |m|

			#kill any existing piece we're moving onto or capturing enpassant
			@pieces.reject!{ |p| (p.position == m.to_coord) || (p.position == m.captured_piece_coord) }	

			#move to that square
			@pieces.each{ |p| p.position = m.to_coord if p.position==m.from_coord }
				
			#reflect castling
			if m.castled==1
				castling_rank = m.to_coord[1].chr
				[['g', 'f', 'h'], ['c', 'd', 'a']].each do |king_file, rook_file, orig_rook_file|
					@pieces.each { |p| p.position = "#{rook_file}#{castling_rank}" if m.to_coord[0].chr==king_file && p.position=="#{orig_rook_file}#{castling_rank}"}
				end
			end
		end
			
	end

	#todo - can dry up these methods 
	def piece_at(pos)
		p = @pieces.find { |piece| piece.position == pos }
	end
	
	def side_occupying(pos)
		p = @pieces.find { |p|  p.position == pos }
		return nil if !p 
		return p.side
	end

	def position_occupied_by?(pos, side)
		p = @pieces.find { |p|  p.position == pos }
		
		return false if ! p
		return (p.side == side)
	end

	def sister_piece_of( piece )
		p = @pieces.find { |p| (p.side == piece.side) && (p.piece_type == piece.piece_type ) && (p.type != piece.type) }
	end
	
	def in_check?( side )
		king_to_check = @pieces.find{ |p| p.type==:king && p.side == side }
		side_to_check = (side==:white) ? :black : :white

		@pieces.select { |p| p.side == side_to_check}.each do |attacker|
			return true if attacker.allowed_moves( self ).include?( king_to_check.position )
		end
		return false
	end

	def is_en_passant_capture?( from_coord, to_coord ) 

		to_rank, to_file = to_coord[1].chr, to_coord[0].chr
		side = piece_at( from_coord ).side 

		capture_rank, advanced_pawn_rank, original_pawn_rank = (side==:white) ? %w{ 6 5 7 } : %w{ 3 4 2 }
		possible_advanced_pawn = piece_at( to_file + advanced_pawn_rank )

		#if behind a pawn
		if (to_rank == capture_rank) && possible_advanced_pawn && (possible_advanced_pawn.piece_type=='pawn') 
			#and that pawn was doubly (not singly) advanced
			@match.moves.find_by_from_coord_and_to_coord( ( to_file + original_pawn_rank ) , possible_advanced_pawn.position ) != nil
		else
			return false
		end

	end
end