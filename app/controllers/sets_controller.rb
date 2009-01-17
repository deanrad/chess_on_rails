# Manages the addition and updating of players and their information
class SetsController < ApplicationController

  def change
    session[:set] = params[:set]
    redirect_to :back
  end

end