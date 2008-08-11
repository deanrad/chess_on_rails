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

  #TODO provide a way to create a new match with someone
  #TODO provide a way (in advance of AJAX) to get a refresh of the state of the game
end
