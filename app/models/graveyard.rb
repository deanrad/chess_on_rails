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

  # Returns how many points that side has (of the opponents pieces) in the graveyard.
  def points_for side
    self.select{ |p| p.side == side.opposite }.inject(0) do |acc, p|
      acc += p.point_value; acc
    end 
  end
end
