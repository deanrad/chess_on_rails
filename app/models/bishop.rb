# move_directions :diagonal, :limit => :none
class Bishop < Piece
  move_directions :diagonal, :limit => :none
  POINT_VALUE=3
  
  def initialize(side, discriminator=nil)
    super(side, :bishop, discriminator)
  end
end
