class MatchController < ApplicationController

  before_filter :authorize

  def index; end
  def show; end
  def new; end
  def update_view; Rails.logger.silence{ render :action => 'update_view' } ; end
  def browser_view_model;   Rails.logger.silence{ render :action => 'browser_view_model' } ; end

  # json for autocomplete
  def players
    render :json => Player.find(:all, :conditions => "name like '#{ params[:term] }%'" ).map(&:name)
  end

  # TODO can consolidate these match actions into one method for nice LOC savings - delegate actions to model
  def resign
    match.resign( request.player )
    match.save!
    redirect_to :action => 'index'
  end
  
  def offer_draw
    match.draw_offerer = request.player
    match.save!
    render :text => 'OK'
  end

  def decline_draw
    match.update_attribute(:draw_offerer, nil)
    render :text => 'OK'
  end
  
  def accept_draw
    return unless match.side_of( request.player ) && match.draw_offerer != request.player
    match.result, match.active = ['Draw by Agreement', 0]
    match.save!
    render :text => 'OK'
  end

  def create( switch_em = params[:opponent_side] =='white' )
    players = [ request.player, Player.find_by_name(params[:opponent_name]) ]
    @match = Match.start!( :players => players.send(switch_em ? :reverse : :to_a),
                           :start_pos => params[:start_pos] )

    ChessNotifier.deliver_match_created(request.opponent(@match), request.player, @match)
    redirect_to match_url(@match.id)
  end

  # TODO make match a thread-local global variable
  def match; request.match; end;  private :match
  
end
