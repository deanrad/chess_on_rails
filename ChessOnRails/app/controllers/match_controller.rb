class MatchController < ApplicationController
	
	before_filter :authorize
	
	# GET /match/1
	def show
		# shows whose move it is 
		@match = Match.find( params[:id] )
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
