# Adds extensions to the move controller
Move.class_eval do
  after_save :notify_of_move_via_email

  def notify_of_move_via_email
    # logger.warn "Notifying by email of move #{self.inspect}"
    mover = match.gameplays[self.side].player
    opponent = match.gameplays[self.side.opposite].player
    ChessNotifier.deliver_opponent_moved(mover, opponent, self)
    rescue => ex
    logger.error "Mail is fed up!  #{ex.message}"
  end
end
