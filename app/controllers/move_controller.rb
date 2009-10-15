class MoveController < ApplicationController

  before_filter :authorize
  rescue_from ArgumentError, :with => :display_error

  #accessible via get or post but should be idempotent on 2x get
  def create
    @match = current_player.matches.find( params[:match_id] || params[:move][:match_id] )

    raise ArgumentError, "You are trying to move on a match you either don't own or is not active" unless @match
    raise ArgumentError, "It is your not your turn to move yet" unless @match.turn_of?( current_player )

    # support a shorter means of passing a notation parameter
    params[:move][:notation] = params[:notation] if params[:move] && !params[:notation].blank?

    return unless params[:move]

    @match.moves << @move = Move.new( params[:move] ) # saves automatically
    
    unless @move.errors.empty?
      flash[:move_error] = @move.errors.messages
    end

    #unceremonious way of saying you just ended the game 
    #redirect_to( :controller => 'match', :action => 'index' ) and return unless @match.active

    redirect_to( match_path(@match) ) and return unless request.xhr? 
  end
  
protected
  def display_error(ex)
    flash[:move_error] = Exception === ex ? ex.message : ex.to_s
    redirect_to( match_url(@match.id) ) and return if @match
  end

end
