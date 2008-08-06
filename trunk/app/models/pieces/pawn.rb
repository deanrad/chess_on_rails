class Pawn < Piece
  def initialize(side, which)
    super(:pawn, side, which)

    #figure out which way is forward
    forward = Sides[@side].advance_direction
    
    #a short line-of-attack in the forward direction
    @lines_of_attack << LineOfAttack.new( [forward, 0] , 2 ) 
    
    #and the diagonal forward moves
    [1,-1].each{ |diag| @lines_of_attack << LineOfAttack.new( [forward, diag], 1 ) }
    
  end
  
  def vector_allowed_from(here, vector)
    return true unless vector == [2,0] or vector == [-2,0] # vector[0].abs = 2
    return Position.new(here).rank == Sides[@side].front_rank
  end
end