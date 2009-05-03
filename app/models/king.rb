class King < Piece
  move_directions :diagonal, :straight, :limit => 1

  def initialize(side, discriminator=nil)
    super(side, :king, discriminator)
  end
end
