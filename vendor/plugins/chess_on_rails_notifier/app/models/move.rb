# Adds extensions to the move controller
Move.class_eval do
  after_save :notify_of_move_via_email

  def notify_of_move_via_email
    logger.warn "Notifying by email of move #{self.inspect}"
  end
end
