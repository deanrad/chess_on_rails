class Match < ActiveRecord::Base

	SIDES = [
		['White', '1'],
		['Black', '2']
	]
	
	belongs_to :player1,	:class_name => 'Player', :foreign_key => 'player1'
	belongs_to :player2,	:class_name => 'Player', :foreign_key => 'player2'
	belongs_to :winning_player, :class_name => 'Player', :foreign_key => 'winning_player'
	
	has_many :moves, :order=>"created_at ASC" 
	
	def initial_board
		return Board.new( self, Chess.initial_pieces, 0 )
	end
	
	def board(as_of_move = :current)
		return Board.new( self, Chess.initial_pieces, as_of_move ) 		
	end
	
	# returns 2 or 1
	def next_to_move
		(moves.count & 1) + 1 	
	end

	def turn_of?( plyr )	
		((plyr == player1) && (next_to_move==1)) || (plyr == player2) && (next_to_move==2)
	end
	
	def side_of( plyr ) 
		return :white if plyr == @player1
		return :black if plyr == @player2
	end

	def lineup
		"#{player1.name} vs. #{player2.name}"
	end

	def resign( plyr )
		write_attribute :result, 'Resigned'
		write_attribute :active, 0
		write_attribute :winning_player, (plyr==player1) ? player2.id : player1.id
	end

end
