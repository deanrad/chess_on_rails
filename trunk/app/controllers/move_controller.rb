
class MoveController < ApplicationController

	rescue_from ArgumentError, :with => :display_error
	rescue_from ActiveRecord::RecordInvalid, :with => :display_error
	
	before_filter :authorize, :get_match

	#accessible via get or post but should be idempotent on 2x get
	def create
		@move = @match.moves.build( params[:move] )

		@move.save!

		#unceremonious way of saying you just ended the game 
		redirect_to( :controller => 'match', :action => 'index' ) and return unless @match.active

		#back to the match if non-ajax
		redirect_to(:back) and return unless request.xhr? 

		#otherwise do a normal status update to refresh UI
		set_match_status_instance_variables
		render :template => 'match/status' and return
	end

	def get_match
		@match = @current_player.active_matches.find( params[:move][:match_id] )
		raise ArgumentError, "You are trying to move on a match you either don't own or is not active" unless @match
		raise ArgumentError, "It is your not your turn to move yet" unless @match.turn_of?( @current_player )
	end

	def display_error(ex)
		flash[:move_error] = ex.to_s
		redirect_to(:back) and return unless request.xhr?

		#xhr
		set_match_status_instance_variables
		render :template => 'match/status' and return
		
	end
end
