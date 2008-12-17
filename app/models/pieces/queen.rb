class Queen< Piece
  
  def initialize(side)
    super(:queen, side)
    
    DIAGONAL_MOTIONS.each{ |move| @lines_of_attack << LineOfAttack.new(move) }
    STRAIGHT_MOTIONS.each{ |move| @lines_of_attack << LineOfAttack.new(move) }
  end

end