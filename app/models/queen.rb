class Queen < Piece
  move_directions :diagonal, :straight, :limit => :none

  def initialize(side)
    super(side, :queen)
  end
end
