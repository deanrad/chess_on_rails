class Bishop < Piece
  move_directions :diagonal, :limit => :none

  def initialize(side, discriminator=nil)
    super(side, :bishop, discriminator)
  end
end
