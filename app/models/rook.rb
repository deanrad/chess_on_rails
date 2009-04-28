class Rook < Piece
  move_directions :straight, :limit => :none

  def initialize(side)
    super(side, :rook)
  end
end
