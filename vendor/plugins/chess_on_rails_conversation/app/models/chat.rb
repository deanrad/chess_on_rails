# A list of messages said by a player within a match
class Chat < ActiveRecord::Base
  include ChatActions

  belongs_to :match
  belongs_to :player

  def to_client_hash
    {
      'type' => 'chat',
      'text' => self.display_text,
      'date' => self.created_at,
      'player' => self.player.name
    }
  end
end
