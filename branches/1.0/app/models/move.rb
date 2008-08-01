# A Move represents what a player did with respect to the pieces on the board in their turn.
# They may have:
# * moved a piece from +from_coord+ to +to_coord+
# * captured a piece at +capture_coord+ (usually but not always equal to +to_coord)
# * castled 
# * promoted a pawn to another piece 
#
# Also stored is the canonical notation for the move, in standard short algebraic form.
# See: http://en.wikipedia.org/wiki/Chess_notation for information on notation and coordinates
class Move < ActiveRecord::Base
  belongs_to :match
  
  def from_coord
    self[:from_coord].to_sym
  end
  def from_coord=(val)
    self[:from_coord] = val.to_s
  end
  
  def to_coord
    self[:to_coord].to_sym
  end
  def to_coord=(val)
    self[:to_coord] = val.to_s
  end
  
  def capture_coord
    self[:capture_coord].to_sym if self[:capture_coord]
  end
  def capture_coord=(val)
    self[:capture_coord] = val.to_s
  end

end
