class BoardController < ApplicationController
	
	#  def display
	#	  raise "" if ! params[:match_id]
	#  end
	
	def physical
		get_ranks_and_files
		
		if params[:side] == :black.to_s
			@files.reverse!
			@ranks.reverse!
		end
		
	end
	
end
