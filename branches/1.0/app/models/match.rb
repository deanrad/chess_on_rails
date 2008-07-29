class Match < ActiveRecord::Base
  
  belongs_to :player1,  :class_name => 'Player'
  belongs_to :player2,  :class_name => 'Player'
  belongs_to :winner,   :class_name => 'Player'
  
  has_many :moves, :order => 'created_at ASC'

  def white
    player1
  end
  def black
    player2
  end
  
end
