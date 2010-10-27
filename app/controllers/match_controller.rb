class MatchController < ApplicationController

  before_filter :authorize

  def index; end
  def show; end
  def new; end

  # json for autocomplete
  def players
    render :json => Player.find(:all, :conditions => "name like '#{ params[:term] }%'" ).map(&:name)
  end

  # give up the ghost
  def resign
    request.match.resign( current_player )
    redirect_to :action => 'index'
  end

  def create( switch_em = params[:opponent_side] =='white' )
    players = [ request.player, Player.find_by_name(params[:opponent_name]) ]
    @match = Match.start!( :players => players.send(switch_em ? :reverse : :to_a),
                           :start_pos => params[:start_pos] )

    ChessNotifier.deliver_match_created(request.opponent(@match), request.player, @match)
    redirect_to match_url(@match.id)
  end

end
