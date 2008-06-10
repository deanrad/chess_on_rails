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

			Piece.types.each do |type|
				if type.to_s.include?( "pawn" )
					@@pieces << Piece.new( side, type, type.to_s[0].chr+ front_rank )
				elsif type==:queens_rook
					@@pieces << Piece.new( side, type, 'a'+back_rank )
				elsif type==:queens_knight
					@@pieces << Piece.new( side, type, 'b'+back_rank )
				elsif type==:queens_bishop
					@@pieces << Piece.new( side, type, 'c'+back_rank )
				elsif type==:queen
					@@pieces << Piece.new( side, type, 'd'+back_rank )
				elsif type==:king
					@@pieces << Piece.new( side, type, 'e'+back_rank )
				elsif type==:kings_bishop
					@@pieces << Piece.new( side, type, 'f'+back_rank )
				elsif type==:kings_knight
					@@pieces << Piece.new( side, type, 'g'+back_rank )
				elsif type==:kings_rook
					@@pieces << Piece.new( side, type, 'h'+back_rank )
				end
			end
		end
		return @@pieces
	end
	
end
