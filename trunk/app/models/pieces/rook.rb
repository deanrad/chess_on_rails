class Rook < Piece

  def initialize(side, which)
    super(:rook, side, which)
    STRAIGHT_MOTIONS.each{ |move| @lines_of_attack << LineOfAttack.new(move) }
  end
  
end