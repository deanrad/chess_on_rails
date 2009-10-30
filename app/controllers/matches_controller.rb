class MatchesController < ApplicationController
  before_filter :authorize
  
  # Shows a match in progress to its players.
  def show; end    

  # Shows which matches the current_player has open.
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
    head :not_modified and return unless status_has_changed?
  end

  # Provides the js of previous boards
  def boards; end

  # Shows a form allowing a player to create a new match with another.
  def new; end

  def resign
    @match = Match.find( params[:id] )
    @match.resign( current_player )
    redirect_to :action => 'index'
  end

  # Recieves the POST to create a new match
  def create
    return unless request.post?

    # find out who they're playing against
    if params[:match]
      @opponent = Player.find_by_name( params[:match][:opponent_name] )
    elsif params[:opponent_id] # some tests use this format
      @opponent = Player.find(params[:opponent_id])
    end

    flash[:error] = "Player not found ! (#{params.inspect})" and return unless @opponent

    # set up players
    contestants = [current_player, @opponent]
    contestants.reverse! if params[:opponent_side] == 'black'
    attrs = {:players => contestants }

    # add start position of game if applicable
    start_pos = params[:start_pos]
    attrs[:start_pos] = start_pos if start_pos and Fen::is_fen?( start_pos )

    # save..
    @match = Match.create( attrs )

    # and set up if necessary
    if start_pos && PGN::is_pgn?( start_pos )
      pgn = PGN.new( start_pos )
      pgn.playback_against( @match )
      logger.warn "Error #{pgn.playback_errors.to_a.inspect} in PGN playback of #{start_pos}" if pgn.playback_errors
    end

    # they're off !
    redirect_to match_url(@match.id) if @match
  end

  def auto_complete_for_player_name
    @players = Player.find(:all)
    player_text = @players.inject("") do |txt, p|
      txt << "  <li>#{p.name}</li>\n"
    end
    render :text => "<ul>\n" + player_text + "</ul>"
  end


### MoveController code below ### 
  rescue_from ArgumentError, :with => :display_error

  #accessible via get or post but should be idempotent on 2x get
  def create_move
    @match = current_player.matches.find( params[:match_id] || params[:move][:match_id] )

    raise ArgumentError, "You are trying to move on a match you either don't own or is not active" unless @match
    raise ArgumentError, "It is your not your turn to move yet" unless your_turn

    # support a shorter means of passing a notation parameter
    params[:move][:notation] = params.delete(:notation) if (params[:move] ||= {}) && !params[:notation].blank?

    return unless params[:move]
$stderr.puts params[:move].inspect

    @move = Move.new( params[:move] )
    @match.moves <<  # saves automatically
    
    unless @move.errors.empty?
      flash[:move_error] = @move.errors.full_messages * "\n"
    end

    #unceremonious way of saying you just ended the game 
    #redirect_to( :controller => 'match', :action => 'index' ) and return unless @match.active

    if request.xhr? 
      render :text => 'OK'
    else
      redirect_to( match_path(@match) )
    end
  end
  
protected
  def display_error(ex)
    flash[:move_error] = Exception === ex ? ex.message : ex.to_s
    redirect_to( match_url(@match.id) ) and return if @match
  end

end
