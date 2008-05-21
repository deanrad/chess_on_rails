class MoveController < ApplicationController
	
	before_filter :authorize
	
	def create
		raise ArgumentError if ! params[:move]

		@move = Move.new( params[:move] )

		puts @move.errors and raise ArgumentError if ! @move.valid?
		raise ArgumentError, "It's not your turn to move" if ! @move.match.turn_of?( @current_player )

		#ensure these computed fields get stored to db - todo move to model if possible
		@move.notation = @move.notate
		@move.castled = @move.notation.include?( "O-" )

		@move.save!
		redirect_to(:back)
	end

end
