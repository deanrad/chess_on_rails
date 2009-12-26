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

    @original_eval_text = @options['eval_text'].dup
    @options['safe_eval_text']  = sanitize_eval_text(@original_eval_text)

    true
  end

  # Attempts to prevent unsafe commands from being evaled
  # TODO Add sanitization routines to this function as you go
  def sanitize_eval_text(text)
    text
  end

  # Does the actual evaluation, error handling, etc..
  def do_eval!
    safe_eval_text = @options['safe_eval_text']
    if safe_eval_text
      begin
        @eval_output = eval(safe_eval_text).pretty_inspect
      rescue Exception => ex
        @eval_output = ex.message + ex.to_s
      end
    end
  end

  # Keeps you from needing a route for controller/action with no ID
  def route_id_to_action
    case params[:id]
      when "console"
      do_eval!
      render :action => 'console'
    end
  end
end

end # if ENV["MAGELLAN_ON"]=="1"
