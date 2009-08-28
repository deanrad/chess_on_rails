# A list of messages said by a player within a match
class Chat < ActiveRecord::Base
  belongs_to :match
  belongs_to :player
end
