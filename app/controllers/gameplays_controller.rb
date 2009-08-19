class GameplaysController < ApplicationController

  def show
    render :text => gameplay.inspect
  end
  alias :index :show

  # POST /gameplay/N/?move_queue=Nc5 Bd3
  def update
    @gameplay = Gameplay.find(params[:id])
    @gameplay.update_attributes(params[:gameplay])
    @gameplay.save!
    render :text => 'Saved.'
  end
end
