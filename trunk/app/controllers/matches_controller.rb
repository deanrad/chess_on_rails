# Deals with the creation and updating of matches, such as creation, resignation
class MatchesController < ApplicationController

  # GET /matches/N
  def show
    @match = Match.find( params[:id] )
  end

  # GET /matches
  def index
    @matches = current_player.matches if current_player
  end
      
end

#TODO - remove this hack that prevents specs from failing on missing metaclass method
class Object
  def metaclass
    (class << self; self; end)
  end
end
