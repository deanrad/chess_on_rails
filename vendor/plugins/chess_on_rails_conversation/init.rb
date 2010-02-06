# Extend core classes with our goodness
Match.class_eval do
  # Chats are messages said by one party or the other during the match.
  has_many :chats, :include => :match
end

Move.class_eval do
  # Defines what a move looks like to a client that was just notified of the move
  # occurring, and needs to refresh. 
  def to_client_hash
    {
      'date' => self.created_at,
      'text' => self.notation,
      'board' => self.board_after,
    }
  end
end
