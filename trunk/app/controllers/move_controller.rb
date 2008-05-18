class MoveController < ApplicationController
	
	before_filter :authorize
	
	def create
		raise ArgumentError if ! params[:move]

		@move = Move.new( params[:move] )

		#if theres not a piece of yours
		
		#@move = Move.new
		#@move.match = @match
		#@move.update_attributes( params[:move] )

		puts @move.errors and raise ArgumentError if ! @move.valid?

		#ensure these computed fields get stored to db - todo move to model if possible
		@move.moved_by = (@current_player == @move.match.player1) ? 1 : 2
		@move.notation = @move.notate
		@move.castled = @move.notation.include?( "O-" )

		@move.save!
		redirect_to(:back)
	end

	#xhr controller action
	def notate
		move = Move.new( params[:move] ) 
		render :text => move.notate
		
	#rescue 
	#	render :text => "?"
	end
end
