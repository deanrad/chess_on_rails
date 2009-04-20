# The participation of a player in a given match
class Gameplay < ActiveRecord::Base
  belongs_to :player
  belongs_to :match

  def move_queue
    @move_queue ||= MoveQueue.new( self[:move_queue] )
  end
  def move_queue= q
    @move_queue = q
    self[:move_queue] = q.to_s
  end

end
