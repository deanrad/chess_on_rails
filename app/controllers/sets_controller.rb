# Manages the set of pieces displayed for this user
# Currently not shown in UI, TODO move to options
class SetsController < ApplicationController

  def change
    session[:set] = params[:set]
    redirect_to :back
  end

end
