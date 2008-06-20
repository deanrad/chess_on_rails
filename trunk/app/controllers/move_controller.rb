class MoveController < ApplicationController

	rescue_from ArgumentError, :with => :display_error
	
	before_filter :authorize

	#accessible via get or post but should be idempotent on 2x get
	def create
		@move = Move.new( params[:move] )

		#@match = Match.find( params[:move][:match_id] )
		#@match.moves << Move.new( params[:move] )

		puts @move.errors and raise ArgumentError if ! @move.valid?
		raise ArgumentError, "It's not your turn to move" if ! @move.match.turn_of?( @current_player )

		@move.save! #not implicit save like appending << to association

		#if they got the other guy on this move 
		#todo - more model-esque - possibly decommissioning this controller and working just with match
		if @move.match.reload.board.in_checkmate?( @current_player == @move.match.player1 ? :black : :white )
			@move.match.winning_player = @current_player
			@move.match.result = 'Checkmate'
			@move.match.active = 0
			@move.match.save

			redirect_to( :controller => 'match', :action => 'index' ) and return
		end

		redirect_to(:back) # this is not yet ajaxian, and no template's been written yet
	end

	def display_error(ex)
		flash[:move_error] = ex.to_s
		redirect_to(:back)
	end
end
