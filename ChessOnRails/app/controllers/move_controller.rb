class MoveController < ApplicationController
	
	before_filter :authorize
	
	def create
		
		#ensure parameters have been passed
		if ! params[:from_coord] || ! params[:to_coord]
			raise ArgumentError, "You must specify a from/to coordinate pair in this version of the game"
		end
        [:from_coord, :to_coord].each do |coord|
            if ! Chess.valid_position?( params[coord] )
                raise ArgumentError, "#{params[coord]} is not a valid Chess board coordinate!"
            end
        end
		
		#bind to the correct match or raise an error
		if params[:match_id]
			
			Player.current.matches.each do |m|
				@match = m if m.id == params[:match_id].to_i
			end
			if ! @match 
				raise ArgumentError, "You do not have access to a match with id #{params[:match_id]}"
			end
		else
			@match = Player.current.match
		end
		
		#if theres not a piece of yours
	end
end
