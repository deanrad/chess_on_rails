#A Board is a snapshot of a match at a moment in time.
class Board

	attr_accessor :pieces
	
	def initialize(pieces)
		@pieces = pieces
	end
	
	def num_active_pieces
		@pieces.length
	end
end