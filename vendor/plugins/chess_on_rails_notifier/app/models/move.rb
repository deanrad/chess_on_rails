# Adds extensions to the move controller
Move.class_eval do
  after_save :notify_of_move_via_email

  # Returns a Time object
  def time_since_last_move
    self.created_at - match.moves[ match.moves.index(self) - 1 ].created_at
  end

  def notify_of_move_via_email
    # TODO move to configuration - dont send email if its been less than 1/24 of a day
    return unless( self.created_at > match.moves.last.created_at + 1.hour )

    # logger.warn "Notifying by email of move #{self.inspect}"
    mover = match.gameplays[self.side].player
    opponent = match.gameplays[self.side.opposite].player
    ChessNotifier.deliver_opponent_moved(opponent, mover, self)
    #rescue => ex
    #logger.error "Mail is fed up!  #{ex.message}"
  end
end
