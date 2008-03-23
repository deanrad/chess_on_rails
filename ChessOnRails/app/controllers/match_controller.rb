class MatchController < ApplicationController
	
	before_filter :authorize
	
	# GET /match/1
	def show
		# shows whose move it is 
	end
	
	# GET /match/  GET /matches/
	def index
		# returns list of playable matches
		@matches = Match.find(:all, "player_id = " + "1")
	end
	
	# GET /match/new
	def create
		#redirects to one created with defaults
	end
end
