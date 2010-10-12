# These little valiant pieces lead us into battle, stepping one or two squares on their first 
# move, only moving forward, etc... 
class Pawn < Piece

  # not using the class macro - see Pawn#allowed_move?
  POINT_VALUE=1 

  # Initializes side and discriminator to :a through :h, if passed
  def initialize(side = :white, discriminator=nil)
    super(side, :pawn, discriminator)
  end

  # The direction pawns may advance, as it would appear in a vector.
  # 1 for white, -1 for black
  def advance_direction
    @side == :white ? 1 : -1
  end

  # The rank this pawn starts the game on
  # 2 or 7 for white or black, respectively
  def home_rank
    @side == :white ? 2 : 7
  end

  # The rank at which this pawn can become a Queen, also called to 'promote'
  # 8 or 1 for white or black, respectively
  def promotion_rank
    @side == :white ? 8 : 1
  end


  # Overrides Piece#allowed_move? to implement pawn's weird behavior
  def allowed_move?( vector, starting_rank = nil ) 
    raise ArgumentError, "You must include the starting rank in Pawn#allowed_moves" unless starting_rank
    case vector[0]
      when 1, 0, -1
        return true if vector[1] == advance_direction
    end
    return vector == [0, 2*advance_direction] && starting_rank == home_rank
  end
end
