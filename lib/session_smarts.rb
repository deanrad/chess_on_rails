module SessionSmarts
  def player;     self[:player_id] && Player.find(self[:player_id]) ; end
  def player= p ; self[:player_id] = p.id ; end
end
