# The participation of a player in a given match
class Gameplay < ActiveRecord::Base
  belongs_to :player
  belongs_to :match
end
