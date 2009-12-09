# A list of messages said by a player within a match
class Chat < ActiveRecord::Base
  include ChatActions

  belongs_to :match
  belongs_to :player

  def to_json
    %Q|{event_type:chat,event_id:c#{id},player:"#{player.name}",text:"#{display_text}"}|
  end
end
