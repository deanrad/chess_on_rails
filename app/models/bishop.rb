class Bishop < Piece
  move_directions :diagonal, :limit => :none

  def initialize(side)
    super(side, :bishop)
  end
end
