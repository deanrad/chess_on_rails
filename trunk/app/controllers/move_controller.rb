
class MoveController < ApplicationController

	rescue_from ArgumentError, :with => :display_error
	
	before_filter :authorize, :get_match

	#accessible via get or post but should be idempotent on 2x get
	def create
		@move = @match.moves.new( params[:move] )

		@move.save! #not implicit save like appending << to association

		#if they got the other guy on this move 
		#todo - more model-esque - possibly decommissioning this controller and working just with match
		if @match.reload.board.in_checkmate?( @current_player == @match.player1 ? :black : :white )
			@match.checkmate_by( @current_player )

			redirect_to( :controller => 'match', :action => 'index' ) and return
		end

		redirect_to(:back) # this is not yet ajaxian, and no template's been written yet
	end

	def get_match
		@match = @current_player.active_matches.find( params[:move][:match_id] )
		raise ArgumentError, "You are trying to move on a match you either don't own or is not active" unless @match
		raise ArgumentError, "It is your not your turn to move yet" unless @match.turn_of?( @current_player )
	end

	def display_error(ex)
		flash[:move_error] = ex.to_s
		redirect_to(:back)
	end
end
