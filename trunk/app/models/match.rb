class Match < ActiveRecord::Base

	SIDES = [  ['White', '1'], ['Black', '2']  ]
	
	belongs_to :player1,	:class_name => 'Player', :foreign_key => 'player1'
	belongs_to :player2,	:class_name => 'Player', :foreign_key => 'player2'
	belongs_to :winning_player, :class_name => 'Player', :foreign_key => 'winning_player'
	
	has_many :moves, :order => 'created_at ASC', :before_add => :evaluate_new_move
	
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

	def opposite_side_of( plyr )
		side_of(plyr) == :white ? :black : :white
	end

	def lineup
		"#{player1.name} vs. #{player2.name}"
	end

	def resign( plyr )
		write_attribute :result, 'Resigned'
		write_attribute :active, 0
		write_attribute :winning_player, (plyr==player1) ? player2.id : player1.id
	end

private
	# callback called on new move to evaluate checkmate situation, etc
	def evaluate_new_move( move )
		#todo move logic here
	end
end
