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
		if( as_of_move==:current)
			@as_of_move = @match.moves.count
		else
			@as_of_move = as_of_move.to_i
		end
		
		#todo rails has much cleaner iteration options than this - learn to use them
		i = 0 
	    for m in @match.moves
			if i < @as_of_move
	
				#kill any existing piece we're moving onto			
				for p in @pieces
					if p.position == m.to_coord
						@pieces.delete(p)
					end
				end

				#move to that square
				for p in @pieces
					if p.position == m.from_coord
						p.position = m.to_coord 
					end
				end
				
			end
			i+=1
		end
			
	end

	def piece_at(pos)
		p = @pieces.find { |piece| piece.position == pos }
		return p
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

	def num_active_pieces
		return 0 if ! @pieces
		@pieces.length
	end

	def sister_piece_of( piece )
		p = @pieces.find { |p| (p.side == piece.side) && (p.piece_type == piece.piece_type ) && (p.type != piece.type) }
	end
	
end