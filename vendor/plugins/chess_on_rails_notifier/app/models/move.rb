# Adds extensions to the move controller
Move.class_eval do
  after_save :notify_of_move_via_email

  def notify_of_move_via_email
    logger.warn "Notifying by email of move #{self.inspect}"
    mover = match.gameplays.send(self.side).player
    opponent = match.gameplays.send(self.side.opposite).player
    ChessNotifier.deliver_opponent_moved(plyr, opp, self)
    rescue
    logger.error "Mail is fed up!"
  end
end
