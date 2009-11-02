# A list of messages said by a player within a match
class Chat < ActiveRecord::Base
  unloadable # fixes copious errors per http://strd6.com/?p=250
  include ChatActions

  # TODO optimize its access to match / match.moves.count to reduce AR queries
  # down to 1 when rendering all chats for a match

  belongs_to :match
  belongs_to :player

end
