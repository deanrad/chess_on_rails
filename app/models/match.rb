class Match < ActiveRecord::Base
  attr_accessible :active, :id, :inprogress, :title
  has_many :gameplays, :include => :player
  has_many :players, through: :gameplays
  
  def player1;  gameplays.first.player ;end
  def player2;  gameplays.last.player  ;end
  
end
