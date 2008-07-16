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

		render :template => 'match/result' and return if @match.active == 0
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
		@match = Match.new
	end

	def resign
		@match = Match.find( params[:id] )
		@match.resign( @current_player )
		redirect_to :action => 'index'
	end

	# POST /match/create
	def create
		return unless request.post?

		@match = Match.new_for( @current_player, Player.find( params[:opponent_id] ), params[:opponent_side] )
		redirect_to :action => 'show', :id=>@match.id if @match
	end
end
