class Chess < Game
	
	require 'Enumerable'
	
	@@files = "abcdefgh"
	@@ranks = "12345678"
	
	def self.initial_board(match)
		
		@@pieces = []
		[:white, :black].each do |side|
			Piece.types.each do |type|
				if type == :pawn
					@@files.each_byte do |file|
						@@pieces << Piece.new( side, type, file.chr+ (side==:white ? '2' : '7') )
					end
				else
					@@pieces << Piece.new( side, type, 'a1' )
				end
			end
		end
		
		return Board.new(match, @@pieces )
	end
	
end
