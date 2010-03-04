class MatchesController < ApplicationController
  before_filter :authenticate

  # TODO can we eliminate this if not necessary ?
  # rescue_from ArgumentError, :with => :display_error

  # Shows a match in progress to its players. 
  def show; end    

  # Shows which matches the current_player has open.
  def index; end

  # match/:id/status?move=N returns javascript to update the board to move N. 
  # If no moves have been made and you query status for move 1 - it will not return
  # javascript to update the board, and will 304 after the first request. Once that
  # move has been made, though, future requests will return JS to update the board
  # and the URL that the client polls for.
  def status
    render :text => "TODO Reimplement MatchesController#status"
    # head :not_modified and return unless status_has_changed?
  end

  # Shows a form allowing a player to create a new match with another.
  def new; end

  # Resigns the current game.
  def resign
    @match = Match[ params[:id].to_i ]
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
    # start_pos = params[:start_pos]
    # attrs[:start_pos] = start_pos if start_pos and Fen::is_fen?( start_pos )

    # save..
    @match = Match.create( attrs )

    # and set up if necessary
    # if start_pos && PGN::is_pgn?( start_pos )
    #  pgn = PGN.new( start_pos )
    #  pgn.playback_against( @match )
    #  logger.warn "Error #{pgn.playback_errors.to_a.inspect} in PGN playback of #{start_pos}" if pgn.playback_errors
    # end

    # they're off !
    redirect_to match_url(@match.id) if @match
  end

  # Provides raw html for autocompletion of player names on the Match#new form.
  def auto_complete_for_player_name
    @players = Player.find(:all)
    player_text = @players.inject("") do |txt, p|
      txt << "  <li>#{p.name}</li>\n"
    end
    render :text => "<ul>\n" + player_text + "</ul>"
  end

  #accessible via get or post but should be idempotent on 2x get
  def create_move
    raise ArgumentError, "You are trying to move on a match you either don't own or is not active" unless match
    raise ArgumentError, "It is your not your turn to move yet" unless your_turn
    raise ArgumentError, "You have not posted a move" unless params[:move]
    
    match.moves << @move = Move.new( params[:move] ) # saves automatically
    
    unless @move.errors.empty?
      flash[:move_error] = @move.errors.full_messages * "\n"
    end

    #unceremonious way of saying you just ended the game 
    #redirect_to( :controller => 'match', :action => 'index' ) and return unless @match.active
    redirect_to( match_path(@match) )
  end

  def show_move
    render :text => "#{params[:move_num]}"
  end

protected
  def display_error(ex)
    flash[:move_error] = Exception === ex ? ex.message : ex.to_s
    redirect_to( match_path(@match.id) ) and return if @match
  end

end
