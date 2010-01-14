# TODO shim in the move_queue functionality to the calling classes (match has_many :moves, :after_add for example)
Gameplay.class_eval do
  def move_queue
    @move_queue ||= MoveQueue.new( self[:move_queue] )
  end
  def move_queue= q
    @move_queue = q
    self[:move_queue] = q.to_s
  end
end
