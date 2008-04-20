class Move < ActiveRecord::Base
	belongs_to :match
	
	def player
		return match.player1 if(moved_by==1) 
		return match.player2 if(moved_by==2) 
	end
	
	def validate
		errors.add(:turn, "It is not your turn to move yet.") if moved_by != match.next_to_move
	end
	
	def notation
		#return saved notation if calculated
		return super if super && (super != "NULL") 
		
		piece_moving = match.board(:current).piece_at( from_coord )
		
		#start off with the pieces own notation
		# strip disambiguator for now - 
		# later only strip if to_coord is in the other pieces allowed moves)
		mynotation = piece_moving.notation
		if( piece_moving.type.to_s.include?("rook") || piece_moving.type.to_s.include?("knight") )
			mynotation = mynotation[0].chr
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