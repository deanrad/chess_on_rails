class MovesController < ApplicationController
  def create
    @match = Match.find( params[:match_id] )
    
    @move = @match.moves.build( params[:move] )
    if @move.valid?
      @match.moves << @move
    else
      flash[:move_in_error] = @move unless @move.valid?
    end
    
    redirect_back_or_default( match_path(@match) ) and return unless request.xhr?
    
    #respond_to do |format|
    #  format.html{ }
    #end
  end
end
