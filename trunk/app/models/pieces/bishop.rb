class Bishop < Piece
  def initialize(side, which)
    super(:bishop, side, which)
    
    DIAGONAL_MOTIONS.each{ |move| @lines_of_attack << LineOfAttack.new(move) }
  end
end