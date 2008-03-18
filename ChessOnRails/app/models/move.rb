class Move < ActiveRecord::Base
	belongs_to :match
	
	def player
		return match.player1 if(moved_by==1) 
		return match.player2 if(moved_by==2) 
	end
end