class Knight < Piece
  @move_vectors = [[-1,2], [1,2], [2,1], [2,-1], [-1,-2], [1,-2], [-2,-1], [-2,1]]
  def initialize(side)
    super(side, :knight)
  end
end
