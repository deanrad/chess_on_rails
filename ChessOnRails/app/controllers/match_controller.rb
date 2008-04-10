class MatchController < ApplicationController
	
	before_filter :authorize
	
	# GET /match/1
	def show
		# shows whose move it is 
		@match = Match.find( params[:id] )
		
		@board = @match.board( @match.moves.count )
		@pieces = @board.pieces
		
		get_ranks_and_files
		@viewed_from_side = (@current_player == @match.player1) ? :white : :black
		@your_turn = ((@current_player == @match.player1) && (@match.next_to_move==1)) || (@current_player == @match.player2) && (@match.next_to_move==2)
		
		if @viewed_from_side == :black
			@files.reverse!
			@ranks.reverse!
		end
	end
	
	# GET /match/  GET /matches/
	def index
		# shows primary match
		@match = @current_player.match
	end
	
	def pieces
		@match = Match.find( params[:id] )

		if( ! params[:move] )		
			@board = @match.initial_board
			@moves_played = @match.moves.count
		else
			@board = @match.board( params[:move] )
			@moves_played = params[:move]
		end
		@pieces = @board.pieces
	end
	
	# GET /match/new
	def create
		#gets from for creating one with defaults
	end
end
