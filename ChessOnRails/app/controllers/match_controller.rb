class MatchController < ApplicationController
	
	before_filter :authorize
	before_filter :fbml_cleanup, :except => 'show'
	
	def fbml_cleanup
		params[:format]='html' if params[:format]=='fbml'
	end

	# GET /match/1
	def show
		# shows whose move it is 
		@match = Match.find( params[:id] )
		
		@board = @match.board( @match.moves.count )
		@pieces = @board.pieces
		
		#begin candidate new method
		@files = Chess.files
		@ranks = Chess.ranks.reverse

		@viewed_from_side = (@current_player == @match.player1) ? :white : :black
		@your_turn = @match.turn_of?( @current_player )
		
		if @viewed_from_side == :black
			@files.reverse!
			@ranks.reverse!
		end

		if @match.active == 0
			render :template => 'match/result' and return
		end

		#end candidate new method
	end
	
	# GET /match/  GET /matches/
	def index
		# shows active matches
		@matches = @current_player.active_matches
	end

	def status 
		@match = Match.find( params[:id] )
		@your_turn = @match.turn_of?( @current_player) 

		#if request.xhr?
		render :partial => "move_indicator", :locals => {:your_turn => @your_turn} 
	end

	def pieces
		@match = Match.find( params[:id] )
		@files = Chess.files
		@ranks = Chess.ranks.reverse

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
	def new
		#gets form for creating one with defaults
		@match = Match.new
		#render :template => "match/new"
	end

	def resign
		@match = Match.find( params[:id] )

		@match.resign( @current_player )

		@match.save!

		redirect_to "/match/" 
	end

	# POST /match/create
	def create
	    if request.post?

		    player1_id = params[:opponent_side] == '1' ? params[:opponent_id] : @current_player.id
		    player2_id = params[:opponent_side] == '2' ? params[:opponent_id] : @current_player.id

		    @match = Match.create( :player1 => Player.find(player1_id), :player2 => Player.find(player2_id) )
	
		    if @match
			redirect_to '/match/show/' + @match.id.to_s
		    end
	    end
	end
end
