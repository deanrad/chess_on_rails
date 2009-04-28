class Pawn < Piece
  def initialize(side = :white, discriminator=nil)
    super(side, :pawn, discriminator)
  end

  def advance_direction
    @side == :white ? 1 : -1
  end

  def home_rank; 
    @side == :white ? 2 : 7
  end

  def allowed_move?( vector, starting_rank = nil ) 
    raise ArgumentError, "You must include the starting rank in Pawn#allowed_moves" unless starting_rank
    case vector[0]
      when 1, 0, -1
        return true if vector[1] == advance_direction
    end
    return vector[1] == 2*advance_direction && starting_rank == home_rank
  end
end
