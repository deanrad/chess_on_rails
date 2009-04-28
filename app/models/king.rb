class King < Piece
  move_directions :diagonal, :straight, :limit => 1

  def initialize(side)
    super(side, :king)
  end
end
