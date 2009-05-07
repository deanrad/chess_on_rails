# Her majesty ! move_directions :diagonal, :straight, :limit => :none
class Queen < Piece
  move_directions :diagonal, :straight, :limit => :none

  def initialize(side, discriminator=nil)
    super(side, :queen, discriminator)
  end
end
