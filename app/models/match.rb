class Match < ActiveRecord::Base
  attr_accessible :active, :id, :inprogress, :title
  has_many :gameplays
  has_many :players, through: :gameplays
  
  def player1;  gameplays.first ;end
  def player2;  gameplays.last  ;end
  
end
