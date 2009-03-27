class MatchController < ApplicationController
  
  before_filter :authorize
  before_filter :fbml_cleanup, :except => 'show'
  
  def fbml_cleanup
    params[:format]='html' if params[:format]=='fbml'
  end

  # GET /match/1
  def show
    # shows whose move it is 
    @match = Match.find( params[:id] )
    
    set_view_vars

    respond_to do |format|
      format.html { render :template => 'match/result' and return if @match.active == 0 }
      format.text { render :text => @match.board.to_s(@viewed_from_side==:black) }
      format.pgn  { render :partial => 'match/move_list' }
    end
  end

  # GET /match/ 
  def index
    # shows active matches
    @matches = @current_player.active_matches
  end

  # match/:id/status?move=N returns javascript to update the board to move N. 
  # If no moves have been made and you query status for move 1 - it will not return
  # javascript to update the board, and will 304 after the first request. Once that
  # move has been made, though, future requests will return JS to update the board
  # and the URL that the client polls for.
  def status 
    @match = Match.find( params[:id] )

    set_view_vars
  end

  # GET /match/new
  def new
    @match = Match.new
  end

  def resign
    @match = Match.find( params[:id] )
    @match.resign( @current_player )
    redirect_to :action => 'index'
  end

  # POST /match/create
  def create
    return unless request.post?

    @match = Match.new( :player1 => @current_player, :player2 => Player.find( params[:opponent_id] ) )
    @match.switch if params[:opponent_side] == 'white'
    @match.save!

    redirect_to match_url(@match.id) if @match
  end

  private 

  #given a @match and @current_player, sets up other instance variables 
  def set_view_vars
    @files = Chess::Files
    @ranks = Chess::Ranks.reverse

    @board = @match.board

    @viewed_from_side = (@current_player == @match.player1) ? :white : :black
    @your_turn = @match.turn_of?( @current_player )

    if @viewed_from_side == :black
      @files.reverse!
      @ranks.reverse!
    end

    @last_move = @match.reload.moves.last
    @status_has_changed = ( params[:move].to_i == @match.moves.length)
  end	
  
end
