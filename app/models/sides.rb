#Contains data on each side in Chess
class Sides
  Side = Struct.new("Side", :color, :back_rank, :front_rank, :advance_direction) #unless defined?('Struct::Side')

  White = Side.new(         :white, 1,          2,          1)
  Black = Side.new(         :black, 8,          7,          -1)
  
  def self.[](side)
    return White if side==:white
    return Black if side==:black
  end
  
  #Used in at least one place - board initialization - to set up each side
  def self.each() # :yields: color, back_rank, front_rank, advance_direction
    yield White.values
    yield Black.values
  end
  
  def self.opposite_of(side)
    return :black if side==:white
    return :white if side==:black
  end
end