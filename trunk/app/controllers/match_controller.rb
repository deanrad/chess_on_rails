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
		
		set_match_status_instance_variables
		@pieces = @board.pieces

		if @match.active == 0
			render :template => 'match/result' and return
		end

	end

	# GET /match/ 
	def index
		# shows active matches
		@matches = @current_player.active_matches
	end

	def status 
		@match = Match.find( params[:id] )

		set_match_status_instance_variables
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

		redirect_to :action => 'index'
	end

	# POST /match/create
	def create
	    if request.post?

		    player1_id = params[:opponent_side] == '1' ? params[:opponent_id] : @current_player.id
		    player2_id = params[:opponent_side] == '2' ? params[:opponent_id] : @current_player.id

		    @match = Match.create( :player1 => Player.find(player1_id), :player2 => Player.find(player2_id) )

		    if @match
			redirect_to :action => 'show', :id=>@match.id
		    end
	    end
	end
end
