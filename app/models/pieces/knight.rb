class Knight < Piece
  def initialize(side, which)
    super(:knight, side, which)
    
    @direct_moves = KNIGHT_MOVES
  end
end