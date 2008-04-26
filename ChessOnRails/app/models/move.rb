class Move < ActiveRecord::Base
	belongs_to :match
	
	def player
		return match.player1 if(moved_by==1) 
		return match.player2 if(moved_by==2) 
	end
	
	def validate
		#easy to disable validation for a superuser to practice gameplay
		return if true

		errors.add(:turn, "It is not your turn to move yet.") if moved_by != match.next_to_move
	end
	
	def notation
		#return saved notation if calculated
		return super if super && (super != "NULL") 
		
		this_board = match.board(:current)
		piece_moving = this_board.piece_at( from_coord )
		
		# start off with the pieces own notation
		mynotation = piece_moving.notation
		
		# disambiguate which piece moved if a 'sister_piece' could have moved there as well
		if( piece_moving.type.to_s.include?("rook") || piece_moving.type.to_s.include?("knight") )
			mynotation = mynotation[0].chr
			sister_piece = this_board.sister_piece_of(piece_moving)
			if( sister_piece != nil && sister_piece.allowed_moves(this_board).include?(to_coord) )
				#prefer using file to disambiguate but use rank if file insufficient
				if ( piece_moving.file != sister_piece.file)
					mynotation += piece_moving.file
				else
					mynotation += piece_moving.rank
				end
			end
		end
		
		#todo figure out captures
		#puts "#{piece_moving.to_s} to #{to_coord}"
		piece_moved_upon  = match.board(:current).piece_at( to_coord )
		
		if piece_moved_upon && (piece_moving.side != piece_moved_upon.side)
			mynotation += "x" 
			captured = true
		end
		
		#destination square
		if( piece_moving.type.to_s.include?("pawn") && !captured )
			mynotation += to_coord[1].chr
		else
			mynotation += to_coord
		end
		
		return mynotation
	end
end