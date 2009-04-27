class MatchController < ApplicationController
  
  before_filter :authorize
  
  # GET /match/1
  def show    
    respond_to do |format|
      format.fbml # should be same as html
      format.html { render :template => 'match/result' and return if match.active == 0 }
      format.text { render :text => match.board.to_s(viewed_from_side==:black) }
      format.pgn  { render :partial => 'match/move_list' }
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
  def status 
  end

  # GET /match/new
  def new
  end

  def resign
    @match = Match.find( params[:id] )
    @match.resign( current_player )
    redirect_to :action => 'index'
  end

  # POST /match/create
  def create
    return unless request.post?
    attrs = {}
    if params[:opponent_side] == 'black'
      attrs = {:white => current_player, :black => Player.find( params[:opponent_id] )}
    else
      attrs = {:black => current_player, :white => Player.find( params[:opponent_id] )}
    end
    setup = params[:start_pos]
    
    attrs[:start_pos] = setup if setup and Fen::is_fen?( setup )
    @match = Match.create( attrs )
    
    if setup and PGN::is_pgn?( setup )
      pgn = PGN.new( setup )
      pgn.playback_against( @match )
      # todo display errors somewhere ??
      # flash[:notice] = pgn.playback_errors.values.join(',') if pgn.playback_errors
    end

    redirect_to match_url(@match.id) if @match
  end

  private 

  def match
    @match ||= if params[:id] 
      Match.find( params[:id] )
    else
      Match.new # params[:match]?
    end
  end

  def board
    @board ||= match.board
  end

  def viewed_from_side
    @viewed_from_side ||= (current_player == match.player1) ? :white : :black
  end

  def your_turn
    @your_turn ||= match.turn_of?( current_player )
  end

  def last_move
    @last_move ||= match.moves.last
  end

  def status_has_changed
    @status_has_changed ||= ( params[:move].to_i <= match.moves.length)
  end

  # the files, in order from the viewed_from_side for rendering
  def files
    @files ||= (viewed_from_side == :black) ? Chess::Files.reverse : Chess::Files
  end

  # the ranks, in order from the viewed_from_side for rendering
  def ranks
    @ranks ||= (viewed_from_side == :black) ? Chess::Ranks : Chess::Ranks.reverse
  end

  helper_method :match, :board, :your_turn, :files, :ranks, :last_move, :status_has_changed

end
