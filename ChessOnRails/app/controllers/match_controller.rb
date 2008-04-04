class MatchController < ApplicationController
	
	before_filter :authorize
	
	# GET /match/1
	def show
		# shows whose move it is 
		@match = Match.find( params[:id] )
		
		@board = @match.initial_board
		@pieces = @board.pieces
		
		get_ranks_and_files
		@viewed_from_side = (@current_player == @match.player1) ? :white : :black
		if @viewed_from_side == :black
			@files.reverse!
			@ranks.reverse!
		end
	end
	
	# GET /match/  GET /matches/
	def index
		# shows primary match
		@match = Player.current.match
	end
	
	# GET /match/new
	def create
		#gets from for creating one with defaults
	end
end
