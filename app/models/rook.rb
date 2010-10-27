# move_directions :straight, :limit => :none
class Rook < Piece
  move_directions :straight, :limit => :none
  POINT_VALUE=5

  def initialize(side, discriminator=nil)
    super(side, :rook, discriminator)
  end
end
