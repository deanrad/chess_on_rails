#Allows the posting of moves to a match or the listing of moves for a given match
class MovesController < ApplicationController

  before_filter :get_match
  
  def create
    
    @move = @match.moves.build( params[:move] )
    if @move.valid?
      @match.moves << @move
    else
      flash[:move_in_error] = @move unless @move.valid?
    end
    
    redirect_to match_path(@match) and return unless request.xhr?
    
    #respond_to do |format|
    #  format.html{ }
    #end
  end
  
  def get_match
    @match = Match.find( params[:match_id] )
    raise ActiveRecord::RecordNotFound unless @match
  end
end
