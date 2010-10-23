class MatchController < ApplicationController

  before_filter :authorize

  def show    
    # respond_to do |format|
    #   format.fbml # should be same as html
    #   format.html { render :template => 'match/result' and return if request.match.active == 0 }
    #   format.text { render :text => request.match.board.to_s(viewed_from_side==:black) }
    #   format.pgn  { render :partial => 'match/move_list' }
    #   format.wml  {} # render :tempate => 'match/show' }
    # end
  end

  def index
    # shows active matches
    @matches = current_player.matches.active
  end

  # edit form for a new match
  def new; end

  # json for autocomplete
  def players
    x = Player.find(:all, :conditions => "name like '#{ params[:term] }%'" ).map do |p|
        p.name
    end
    render :text => x.to_json, :layout => false
  end

  # give up the ghost
  def resign
    request.match.resign( current_player )
    redirect_to :action => 'index'
  end

  # start the fun
  # TODO error handling in MatchController#create
  def create
    req_players = [ request.player, Player.find_by_name(params[:opponent_name]) ]
    match_players = params[:opponent_side] =='white' ? req_players.reverse : req_players

    @match = Match.start!( :players => match_players, :start_pos => params[:start_pos] )

    ChessNotifier.deliver_match_created( req_players.last, req_players.first, self)
    
    redirect_to match_url(@match.id)
  end

private
  # Gets you some of the way to doing remote ajax (ids must be the same in both dbs as well)
  # def default_url_options( options = nil)
  #   { :host => 'www.chessonrails.com'}
  # end

end
