class Match < ActiveRecord::Base
	
	belongs_to :player1, :class_name=>"Player",
    :foreign_key=>"player1"
	belongs_to :player2, :class_name=>"Player",
    :foreign_key=>"player2"
	
	has_many :moves, :order=>"created_at ASC"
	
	def initial_board
		return @board if @board
		
		@board = Chess.initial_board( self )
		return @board
	end
		
	def next_to_move
		#todo may have to be revised - is castling actually two moves ?
		if moves.count & 1 == 0
			return 1
		else 
			return 2
		end
	end
	
#	def validate
#		last_moved_by = -1
#		moves.each do |m|
#			if (last_moved_by == m.moved_by)
#				errors.add(:order, "The other player hasn't gone yet, wait your turn !")
#				return
#			end
#			last_moved_by = m.moved_by
#		end
#	end
	
end
