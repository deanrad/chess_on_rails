class Sides
  def self.each() # :yields: color, back_rank, front_rank, advance_direction
    yield :white, 1, 2, 1
    yield :black, 8, 7, -1
  end
end