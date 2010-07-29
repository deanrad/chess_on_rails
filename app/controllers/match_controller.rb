class MatchController < ApplicationController

  before_filter :authorize

  # GET /match/1
  def show    
    respond_to do |format|
      format.fbml # should be same as html
      format.html { render :template => 'match/result' and return if request.match.active == 0 }
      format.text { render :text => request.match.board.to_s(viewed_from_side==:black) }
      format.pgn  { render :partial => 'match/move_list' }
      format.wml  { render :tempate => 'match/show' }
    end
  end

  # GET /match/ 
  def index
    # shows active matches
    @matches = current_player.matches.active
  end

  # match/:id/status?move=N returns javascript to update the board to move N. 
  # If no moves have been made and you query status for move 1 - it will not return
  # javascript to update the board, and will 304 after the first request. Once that
  # move has been made, though, future requests will return JS to update the board
  # and the URL that the client polls for.
  def status; end

  # provides the js of previous boards
  def boards; end

  # edit form for a new match
  def new; end

  # give up the ghost
  def resign
    request.match.resign( current_player )
    redirect_to :action => 'index'
  end

  # start the fun
  # TODO error handling in MatchController#create
  def create

    players = [ request.player, Player.find( params[:opponent_id] ) ]
    players.reverse! if params[:opponent_side] == 'white'

    @match = Match.start( :players => players, :start_pos => params[:start_pos] )
    
    redirect_to match_url(@match.id)
  end

end
