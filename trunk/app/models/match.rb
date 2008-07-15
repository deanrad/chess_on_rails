class Match < ActiveRecord::Base

	SIDES = [  ['White', '1'], ['Black', '2']  ]
	
	belongs_to :player1,	:class_name => 'Player', :foreign_key => 'player1'
	belongs_to :player2,	:class_name => 'Player', :foreign_key => 'player2'
	belongs_to :winning_player, :class_name => 'Player', :foreign_key => 'winning_player'
	
	has_many :moves, :order => 'created_at ASC'
	
	def initial_board
		return Board.new( self, Chess.initial_pieces, 0 )
	end
	
	def board(as_of_move = :current)
		return Board.new( self, Chess.initial_pieces, as_of_move ) 		
	end
	
	def turn_of?( plyr )	
		self.next_to_move == side_of(plyr)
	end

	def next_to_move
		(moves.count & 1 == 0) ? :white : :black
	end

	def side_of( plyr ) 
		return :white if plyr == player1
		return :black if plyr == player2
	end

	def player_on_side( side )
		return player1 if side == :white
		return player2 if side == :black
	end

	def opposite_side_of( plyr )
		side_of(plyr) == :white ? :black : :white
	end

	def lineup
		"#{player1.name} vs. #{player2.name}"
	end

	def resign( plyr )
		self.result, self.active = ['Resigned', 0]
		self.winning_player = (plyr == player1) ? player2 : player1
		save!
	end

	def checkmate_by( side )
		self.result, self.active = ['Checkmate', 0]
		self.winning_player = player_on_side( side )
		save!
	end

end
