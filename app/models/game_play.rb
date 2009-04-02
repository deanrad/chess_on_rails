# The participation of a player in a given match
class GamePlay < ActiveRecord::Base
  belongs_to :player
  belongs_to :match
end
