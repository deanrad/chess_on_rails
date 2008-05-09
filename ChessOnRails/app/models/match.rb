class Match < ActiveRecord::Base
	
	belongs_to :player1, :class_name=>"Player",
    :foreign_key=>"player1"
	belongs_to :player2, :class_name=>"Player",
    :foreign_key=>"player2"
	
	has_many :moves, :order=>"created_at ASC"
	
	def initial_board
		return Board.new( self, Chess.initial_pieces, 0 )
	end
	
	def board(as_of_move = :current)
		return Board.new( self, Chess.initial_pieces, as_of_move ) 		
	end
	
	def next_to_move
		#todo may have to be revised - is castling actually two moves ?
		if moves.count & 1 == 0
			return 1
		else 
			return 2
		end
	end

	def turn_of?( plyr )	
		((plyr == player1) && (next_to_move==1)) || (plyr == player2) && (next_to_move==2)
	end
	
	def side_of( plyr ) 
		return :white if plyr == @player1
		return :black if plyr == @player2
		return nil
	end
	
	def lineup
		"Blah vs Blah"
	end
end
