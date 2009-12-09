Match.class_eval do
  # Chats are messages said by one party or the other during the match.
  has_many :chats, :include => :match

  # Events are the ordered series of moves or chats that have happened
  # during the match.
  # Arguments since_idx - constrains events returned to be those that occurred
  # after this value
  def events since_idx = nil
    return @events if @events
    @events = (moves + chats).sort do |a, b|
      a.created_at <=> b.created_at
    end
    @events.each_with_index do |ev, idx|
      ev[:event_idx] = idx
    end
    @events
  end
end
