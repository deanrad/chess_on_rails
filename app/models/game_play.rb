# The participation of a player in a given match
class GamePlay < ActiveRecord::Base
  belongs_to :player
  belongs_to :match

  # currently works in dev but not test environment !
  named_scope :white, :conditions => { :black => false }
  named_scope :black, :conditions => { :black => true }
end
