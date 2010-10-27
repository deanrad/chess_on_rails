# One Wild and Crazy Horse, moves "2 in one direction and 1 in the other"
class Knight < Piece
  @move_vectors = [[-1,2], [1,2], [2,1], [2,-1], [-1,-2], [1,-2], [-2,-1], [-2,1]]
  POINT_VALUE=3
  
  def initialize(side, discriminator=nil)
    super(side, :knight, discriminator)
  end
end
