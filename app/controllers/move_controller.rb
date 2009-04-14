class MoveController < ApplicationController

  rescue_from ArgumentError, :with => :display_error
  rescue_from ActiveRecord::RecordInvalid, :with => :display_error
  
  before_filter :authorize

  #accessible via get or post but should be idempotent on 2x get
  def create
    @match = current_player.matches.find( params[:match_id] || params[:move][:match_id] )

    raise ArgumentError, "You are trying to move on a match you either don't own or is not active" unless @match
    raise ArgumentError, "It is your not your turn to move yet" unless @match.turn_of?( current_player )

    if params[:move]
      @match.moves << @move = Move.new( params[:move] )
    elsif params[:notation]
      @match.moves << @move = Move.new( :notation => params[:notation] )
    end
    
    @match.save! #only here to trigger validation

    #unceremonious way of saying you just ended the game 
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
    #back to the match if non-ajax
    redirect_to( match_path(@match) ) and return unless request.xhr? 
    
    #otherwise do a normal status update to refresh UI
    set_view_vars
    render :template => 'match/status' and return
  end

  def display_error(ex)
    if ex.kind_of?(ArgumentError)
      flash[:move_error] = ex.to_s
    else
      flash[:move_error] = ex.record.moves.last.errors.to_a.map{|e| e[1]}.join "<br/>\n"
    end
    
    #if request.xhr?
    #  set_match_status_instance_variables
    #  render :template => 'match/status' and return
    #end

    redirect_to( match_url(@match.id) ) and return if @match
    
  end

  # duplicate of method in match_controller - ugh - should use helper pattern instead
  # of this crap
  def set_view_vars
    @files = Chess::Files
    @ranks = Chess::Ranks.reverse

    @board = @match.board

    @viewed_from_side = (current_player == @match.player1) ? :white : :black
    @your_turn = @match.turn_of?( current_player )

    if @viewed_from_side == :black
      @files.reverse!
      @ranks.reverse!
    end

    @last_move = @match.reload.moves.last
    @status_has_changed = ( params[:move].to_i == @match.moves.length)
  end	

end
