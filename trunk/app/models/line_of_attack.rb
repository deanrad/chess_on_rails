#Bishops, Rooks and Queens move by lines of attack. A line of attack in chess can be no 
# longer than seven squares (a1 to h8) and the board class will consider a line of attack
# moot when it ends in a capture or is blocked by your own piece, or goes off the board 
class LineOfAttack
  
  #vector is of the form [2,-1] with the forward direction listed first
  attr_accessor :vector, :limit
  
  def initialize( vector, limit=7)
    @vector, @limit = [vector, limit]
  end
  
  #for [1,1] limit 7 would yield [1,1] [2,2] and so forth in order of increasing distance
  def each()
    (1..limit).each do |dist|
      yield vector.map{ |dir| dir*=dist }
    end
  end
  
end