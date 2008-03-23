class Game
	#the actual values for ranks and files are overridden by the game
	@@ranks = ""
	@@files = ""
	
	def self.valid_position?(pos)
		return false if pos.length != 2
		return false if ! @@ranks.include? pos[0]
		return false if ! @@files.include? pos[1]
		return true
	end
end
