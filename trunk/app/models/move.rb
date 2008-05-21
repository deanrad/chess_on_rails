class Move < ActiveRecord::Base
	belongs_to :match

	def player
		return match.player1 if(moved_by==1) 
		return match.player2 if(moved_by==2) 
	end
	
	def validate
		errors.add(:match, "You have not specified which match.") and raise ArgumentError, "No match" if ! match
		errors.add(:active, "You cannot make a move for an inactive match, silly !") if ! match.active
		[from_coord, to_coord].each do |coord|
			raise ArgumentError, "#{coord} is not a valid coordinate" if ! Chess.valid_position?( coord )
		end
	end

	def before_save
	end
	
	def notate
		
		this_board = match.board(:current)
		piece_moving = this_board.piece_at( from_coord )
		
		# start off with the pieces own notation
		mynotation = piece_moving.notation
		
		# disambiguate which piece moved if a 'sister_piece' could have moved there as well
		if( piece_moving.piece_type=="rook") || (piece_moving.piece_type=="knight")
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
		
		#castling
		if ( piece_moving.piece_type=="king")
			if( from_coord[0].chr=="e" && to_coord[0].chr=="g")
				mynotation="O-O"
			end
			if( from_coord[0].chr=="e" && to_coord[0].chr=="c")
				mynotation="O-O-O"
			end
		end
		
		#check - from destination position, if opposing king is on any of the moved piece's
		# next allowed moves, the king is in check
		piece_moving.position = to_coord
		piece_moving.allowed_moves( this_board ).each do |square|
			piece_on_square = this_board.piece_at( square )
			if (piece_on_square != nil) && (piece_on_square.side != piece_moving.side) && (piece_on_square.type == :king)
				check = true
				mynotation += "+"
			end
		end
		piece_moving.position = from_coord #move back
		
		return mynotation
	end
end