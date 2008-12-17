# Deals with the creation and updating of matches, such as creation, resignation
class MatchesController < ApplicationController

  # GET /matches/N
  def show
    @match = Match.find( params[:id], :include => :moves )
  end

  # GET /matches
  def index
    @matches = current_player.matches if current_player
  end

  # GET /matches/new
  def new
    @match = Match.new( :player1 => current_player )
    @opponents = Player.find(:all) #can play self for now
  end

  # POST /matches/create
  def create
    #todo allow match to be created with current player as player2 as well
    @match = Match.new( params[:match] ) #sets player2
    @match.player1 = current_player
    @match.switch_sides! if  ! params[:current_player_plays_black].blank?
    @match.save
    redirect_to @match
  end

  #TODO provide a way to create a new match with someone
  #TODO provide a way (in advance of AJAX) to get a refresh of the state of the game
end
