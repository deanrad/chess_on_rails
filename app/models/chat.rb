class Chat < ActiveRecord::Base
  belongs_to :match
  belongs_to :player

  before_save :sanitize_text

  def to_json
    {:id => id, :player => player.name, :time => created_at.strftime("%a %H:%M"), :text => text}.to_json
  end
  
  private
  def sanitize_text
    self.text = self.text.gsub( '<', '&lt;' ).gsub( '>', '&gt;' )
  end
end
