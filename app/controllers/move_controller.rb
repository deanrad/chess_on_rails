
class MoveController < ApplicationController

  rescue_from ArgumentError, :with => :display_error
  rescue_from ActiveRecord::RecordInvalid, :with => :display_error
  
  before_filter :authorize, :get_match

  #accessible via get or post but should be idempotent on 2x get
  def create
    #render :text => "#{params[:match_id] + params[:notation]}" and return
    
    if params[:move]
      @match.moves << Move.new( params[:move] )
    elsif params[:notation]
      @match.moves << Move.new( :notation => params[:notation] )
    end
    
    @match.save! #only here to trigger validation
    
    #unceremonious way of saying you just ended the game 
    redirect_to( :controller => 'match', :action => 'index' ) and return unless @match.active

    respond_to do |format|
      format.html{
        #back to the match if non-ajax
        redirect_to( match_path(@match) ) and return unless request.xhr? 

        #otherwise do a normal status update to refresh UI
        set_match_status_instance_variables
        render :template => 'match/status' and return
      }
      format.text{
        render :text => @match.board.to_s( @viewed_from_side==:black )
      }
    end
  end
  
protected
  def get_match
    @match = @current_player.active_matches.find( params[:match_id] || params[:move][:match_id] )

    raise ArgumentError, "You are trying to move on a match you either don't own or is not active" unless @match
    raise ArgumentError, "It is your not your turn to move yet" unless @match.turn_of?( @current_player )
  end

  def display_error(ex)
    flash[:move_error] = ex.to_s
    
    if request.xhr?
      set_match_status_instance_variables
      render :template => 'match/status' and return
    end

    redirect_to( match_url(@match.id) ) and return if @match
    
  end
end
