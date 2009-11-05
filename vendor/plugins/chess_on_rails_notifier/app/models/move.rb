# Adds extensions to the move controller
Move.class_eval do
  after_save :notify_of_move_via_email

  # Returns a Time object
  def time_since_last_move
    self.created_at - match.moves[ match.moves.index(self) - 1 ].created_at
  end

  # Sends an email notification if this is the first move, or its been
  # long enough since the previous move
  # TODO move time window to configuration or let player control
  def notify_of_move_via_email
    if ! match.moves.last.nil?
      return if self.created_at < match.moves.last.created_at + 1.hour
    end

    logger.warn "Notifying by email of move #{self.inspect}"
    mover = match.gameplays[self.side].player
    opponent = match.gameplays[self.side.opposite].player
    ChessNotifier.deliver_opponent_moved(opponent, mover, self)
    #rescue => ex
    #logger.error "Mail is fed up!  #{ex.message}"
  end
end
