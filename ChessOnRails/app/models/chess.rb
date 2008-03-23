class Chess < Game
	
	#TODO: pieces will become @@board and contain union of piece and position data ...
	# (exactly as board is supposed to have)
	@@pieces = nil
	@@chess_initial_board_file = "C:\\ChessOnRails\\ChessOnRails\\config\\chess\\initial_board.yaml"

	@@ranks = "abcdefgh"
	@@files = "12345678"
	
	def self.initial_board
		return @@pieces if @@pieces
		
		@@pieces = []
		@@pieces << Piece.new
		
		begin
			diskstrm = File.open( @@chess_initial_board_file )
			@@pieces = YAML::load( diskstrm )
		rescue
			raise "Could not load initial pieces from #{@@chess_initial_board_file}"
		ensure
			diskstrm.close
		end
		
		return @@pieces
	end
end
