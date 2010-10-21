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

    this_match = match_path(@match) + (request.mobile? ? '.wml' : '')
    
    [:black, :white].each do |side| 
      match.checkmate_by(side.opposite) if @match.reload.board.in_checkmate?(side)
    end
    
    # was Move#notify - moved out of model
    begin
      opponent, mover = match.send(board.side_to_move), match.send(board.side_to_move.opposite)
      ChessNotifier.deliver_player_moved(opponent, mover, @move)
    rescue Exception => ex
      $stderr.puts ex.inspect
    end
    
    if request.xhr? || true
      render :json => @move.to_json
    else
      redirect_to( this_match ) and return
    end
    
  end
  
end
