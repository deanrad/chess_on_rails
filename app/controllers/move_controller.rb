class MoveController < ApplicationController

  before_filter :authorize

  #accessible via get or post but should be idempotent on 2x get
  def create
    @match = request.match

    raise ArgumentError, "You are trying to move on a match you either don't own or is not active" unless @match
    raise ArgumentError, "It is your not your turn to move yet" unless request.your_turn?

    @match.moves << @move = Move.new( params[:move] )
    flash[:error] = @move.errors.full_messages unless @move.id

    # unceremonious way of saying you just ended the game 
    redirect_to( :controller => 'match', :action => 'index' ) and return unless @match.active
    respond_to do |format|
      format.html{ create_respond }
      format.fbml{ create_respond }
      format.text{
        render :text => @match.board.to_s( @viewed_from_side==:black )
      }
    end
  end
  
protected
  def create_respond
    this_match = match_path(@match)
    this_match << ".wml" if request.mobile?
    redirect_to( this_match ) and return unless request.xhr? 
    
    #otherwise do a normal status update to refresh UI
    render :template => 'match/status' and return
  end

end
