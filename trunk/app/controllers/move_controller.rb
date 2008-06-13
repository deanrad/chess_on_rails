class MoveController < ApplicationController
	
	before_filter :authorize

	#accessible via get or post but should be idempotent on 2x get
	def create
		@move = Move.new( params[:move] )

		puts @move.errors and raise ArgumentError if ! @move.valid?
		raise ArgumentError, "It's not your turn to move" if ! @move.match.turn_of?( @current_player )

		@move.save! #not implicit save like appending << to association

		redirect_to(:back) # this is not yet ajaxian, and no template's been written yet
	end

end
