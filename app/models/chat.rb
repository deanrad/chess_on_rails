class Chat < ActiveRecord::Base
  belongs_to :match
  belongs_to :player

  before_save :sanitize_text

  def board_num
    return @board_num if @board_num
    return @board_num=0 if match.moves.length == 0
    
    match.moves.each_with_index do |mv, idx|
      @board_num = idx # we stay one behind so we return the correct one
      return @board_num if mv.created_at > self.created_at
    end
    return @board_num+1
  end

  def created_at_local
    created_at.in_time_zone( 'America/Chicago' )
  end
  def to_json
    {
      :id         => id, 
      :player     => player.name,
      :time       => created_at_local.strftime("%a %H:%M"),
      :text       => text,
      :board_num  => board_num
    }.to_json
  end
  
  private
  def sanitize_text
    self.text = self.text.gsub( '<', '&lt;' ).gsub( '>', '&gt;' )
  end
end
