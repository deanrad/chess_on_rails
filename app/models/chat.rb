class Chat < ActiveRecord::Base
  belongs_to :match
  belongs_to :player
  
  def to_json
    {:id => id, :player => player.name, :time => created_at.strftime("%a %H:%M"), :text => text}.to_json
  end
end
