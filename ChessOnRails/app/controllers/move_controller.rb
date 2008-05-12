class MoveController < ApplicationController
	
	before_filter :authorize
	
	def create


		#ensure parameters have been passed
		#render ( :text => "Thing was #{params[:move][:from_coord]}" )
		#return
		
		#pass upwards so existing tests dont fail even though we pass differently now 
		params[:from_coord] = params[:move][:from_coord] if ! params[:from_coord]
		params[:to_coord] = params[:move][:to_coord] if ! params[:to_coord]
		params[:match_id] = params[:move][:match_id] if ! params[:match_id] && params[:move][:match_id] 
		
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
			@current_player.matches.each do |m|
				@match = m if m.id == params[:match_id].to_i
			end
		else
			@match = @current_player.match
		end

		if ! @match 
			raise ArgumentError, "You have not specified which match"
		end
		
		#if theres not a piece of yours
		
		
		@move = Move.new
		@move.match = @match
		@move.update_attributes( params[:move] )
		@move.moved_by = (@current_player == @match.player1) ? 1 : 2
		@move.notation = @move.notate

		@move.save!
		redirect_to(:back)
	end

	#xhr controller action
	def notate
		params[:from_coord] = params[:move][:from_coord] if ! params[:from_coord]
		params[:to_coord] = params[:move][:to_coord] if ! params[:to_coord]
		params[:match_id] = params[:move][:match_id] if ! params[:match_id] && params[:move][:match_id] 

		move = Move.new( :match_id => params[:match_id], :from_coord => params[:from_coord], :to_coord => params[:to_coord] ) 
		
		render :text => move.notate
		
	#rescue 
	#	render :text => "?"
	end
end
