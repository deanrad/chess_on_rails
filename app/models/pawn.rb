class Pawn < Piece
  def initialize(side = :white)
    super(side, :pawn)
  end
  def notation(file = nil)
    raise "Cannot notate a pawn without passing in its file" unless file
    super
  end
end
