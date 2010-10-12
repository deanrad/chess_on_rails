class MoveController < ApplicationController

  before_filter :authorize

  #accessible via get or post but should be idempotent on 2x get
  def create
    @match = request.match

    raise ArgumentError, "You are trying to move on a match you either don't own or is not active" unless @match
    raise ArgumentError, "It is your not your turn to move yet" unless request.your_turn?

    @match.moves << @move = Move.new( params[:move] )
    
    # Oh Rails, you make me weep. You only like the above moves << Move.new syntax :(
    # @match.moves.build( params[:move] )
    # @move.save
    flash[:error] = @move.errors.full_messages unless @move.id

    this_match = match_path(@match)
    this_match << ".wml" if request.mobile?
    if request.xhr? || true
      render :json => @move.to_json
    else
      redirect_to( this_match ) and return
    end
    
  end
  
end
