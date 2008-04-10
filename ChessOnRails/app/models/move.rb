class Move < ActiveRecord::Base
	belongs_to :match
	
	def player
		return match.player1 if(moved_by==1) 
		return match.player2 if(moved_by==2) 
	end
	
	def validate
		errors.add(:turn, "It is not your turn to move yet.") if moved_by != match.next_to_move
	end
end