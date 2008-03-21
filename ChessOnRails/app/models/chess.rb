class Chess < Game
	
	@@pieces = nil
	@@chess_pieces_file = "C:\\ChessOnRails\\ChessOnRails\\config\\chess\\initial_pieces.yaml"
	
	def self.initial_pieces
		return @@pieces if @@pieces
		
		@@pieces = []
		@@pieces << Piece.new
		
		begin
			diskstrm = File.open( @@chess_pieces_file )
			@@pieces = YAML::load( diskstrm )
		rescue
			raise "Could not load initial pieces from #{@@chess_pieces_file}"
		ensure
			diskstrm.close
		end
		
		return @@pieces
	end
end
