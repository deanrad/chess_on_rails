class User < ActiveRecord::Base
  belongs_to :playing_as, :class_name => "Player", :foreign_key => "playing_as"

  # allows user to set the name they are playing as 
  def player_name=( val )
    playing_as.name = val
    playing_as.save! 
  end

end
