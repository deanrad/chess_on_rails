class BoardController < ApplicationController

  def display
	  raise "" if ! params[:match_id]
  end
  def physical
	@files = Chess.files
	@ranks = Chess.ranks.reverse

	if params[:side] == :black.to_s
		@files.reverse!
		@ranks.reverse!
	end
  end
  
end
