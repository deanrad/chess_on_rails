class Chess 	

	Files = "abcdefgh"
	Ranks = "12345678"

	def self.valid_position?(pos)
		return false if !pos
		return false if pos.length != 2
		return false if ! Files.include? pos[0]
		return false if ! Ranks.include? pos[1]
		
		true
	end
	def self.initial_pieces
		
		@@pieces = []
		
		
		[:white, :black].each do |side|
			front_rank = (side==:white ? '2' : '7')
			back_rank = (side==:white ? '1' : '8')

			('a'..'h').each do |file|
				@@pieces << Piece.new( side, (file + '_pawn').to_s, file + front_rank )
			end

			@@pieces << Piece.new( side, :queens_rook, 'a'+back_rank )
			@@pieces << Piece.new( side, :queens_knight, 'b'+back_rank )
			@@pieces << Piece.new( side, :queens_bishop, 'c'+back_rank )
			@@pieces << Piece.new( side, :queen, 'd'+back_rank )
			@@pieces << Piece.new( side, :king, 'e'+back_rank )
			@@pieces << Piece.new( side, :kings_bishop, 'f'+back_rank )
			@@pieces << Piece.new( side, :kings_knight, 'g'+back_rank )
			@@pieces << Piece.new( side, :kings_rook, 'h'+back_rank )

		end
		return @@pieces
	end
	
end
