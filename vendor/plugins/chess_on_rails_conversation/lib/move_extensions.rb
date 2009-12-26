# Adds good jsonizing to move
Move.class_eval do
  include ChatActions

  def to_json
    %Q|{event_type:move,event_id:m#{id},text:"#{notation}",board:#{board_after.to_json}}|
  end
end
