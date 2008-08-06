class King < Piece
  def initialize(side)
    super(:king, side)
    
    DIAGONAL_MOTIONS.each{ |move| @lines_of_attack << LineOfAttack.new(move, 1) }      
    STRAIGHT_MOTIONS.each{ |move| @lines_of_attack << LineOfAttack.new(move, 1) }      
    
    #castling, king and queenside respectively works like a line of attack
    # in that no piece may lie between you and that square
    @lines_of_attack << LineOfAttack.new( [0, 2], 1) 
    @lines_of_attack << LineOfAttack.new( [0,-3], 1) 
      
  end

end