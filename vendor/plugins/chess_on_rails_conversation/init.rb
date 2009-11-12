# Load chat model and controller.
# We still the require the migration to live in the main app, oh well..
Match.class_eval do
  # Chats are messages said by one party or the other during the match.
  has_many :chats, :include => :match
end
