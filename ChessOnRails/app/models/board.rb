#A Board is a snapshot of a match at a moment in time.
class Board

	attr_accessor :match
	attr_accessor :pieces
	attr_accessor :as_of_move
	
	def initialize(match, pieces, as_of_move=:current)
		@match = match
		@pieces = pieces
		@as_of_move = as_of_move
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
	
	def validate
	end
end