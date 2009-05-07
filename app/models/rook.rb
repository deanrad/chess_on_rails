# move_directions :straight, :limit => :none
class Rook < Piece
  move_directions :straight, :limit => :none

  def initialize(side, discriminator=nil)
    super(side, :rook, discriminator)
  end
end
