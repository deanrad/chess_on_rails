class Match < ActiveRecord::Base

  belongs_to :player1, :class_name=>"Player",
    :foreign_key=>"player1"
  belongs_to :player2, :class_name=>"Player",
    :foreign_key=>"player2"
	
  def next_to_move
	  return player1
  end
  
end
