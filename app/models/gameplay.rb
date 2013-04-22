class Gameplay < ActiveRecord::Base
  attr_accessible :match_id, :player_id
  
  belongs_to :match
  belongs_to :player
end
