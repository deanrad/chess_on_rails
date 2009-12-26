# MagellanController - the navigatiest of all explorers

if ENV["MAGELLAN_ON"]=="1"

class MagellanController < ApplicationController
#  unloadable # fixes copious errors per http://strd6.com/?p=250

  before_filter :instant_params
  before_filter :route_id_to_action

  def index
    # render :template => 'index'
  end

  def console
    # render :template => 'console'
  end

  private

  # Deconstruct our HTTP params into instance variables
  def instant_params
    @options = params.clone

    # We are trying to indicate the requests' parameters
    %w{action id controller}.each{|p| @options.delete(p) }
    true
  end

  # Keeps you from needing a route for controller/action with no ID
  def route_id_to_action
    case params[:id]
      when "console"
      render :action => 'console'
    end
  end
end

end # if ENV["MAGELLAN_ON"]=="1"
