# The graveyard is an array of killed pieces for a match.
class Graveyard < Array
  # Allow graveyard[:white, :queen] to select the white queen, for example.
  def [] *args
    if args.length == 2 
      self.select{ |p| p.side == args[0] && p.function == args[1] }
    else
      super
    end
  end

  # For the pieces of your opponent you have, the sum of their point values.
  # Arg side: the side we're totalling for
  def points_for side
    select{ |p| p.side == side.opposite }.map(&:point_value).reduce(&:+) || 0
  end
end
