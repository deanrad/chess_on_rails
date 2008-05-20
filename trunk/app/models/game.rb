#todo - can remove the distinction between chess and game and lose some code 
class Game
	#the actual values for ranks and files are overridden by the game
	@@ranks = ""
	@@files = ""
	
	def self.files
		@@files
	end
	def self.ranks
		@@ranks
	end
	def self.initial_board
		return nil
	end
	def self.valid_position?(pos)
		return false if !pos
		return false if pos.length != 2
		return false if ! @@files.include? pos[0]
		return false if ! @@ranks.include? pos[1]
		
		true
	end
	
	def self.maximum_move_length
		return files.length
	end
end
