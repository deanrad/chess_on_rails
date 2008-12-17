# Position represents one of the squares of the board and encapsulates logic for relative positions
# Through this class you can determine if a square is still on the board, add a vector to a square
# to get another, test the file and rank, etc...
class Position
  # The string based array of all allowed positions. These are interned at load time for :a4 style access
  POSITIONS = %w( a8 b8 c8 d8 e8 f8 g8 h8  
                  a7 b7 c7 d7 e7 f7 g7 h7
                  a6 b6 c6 d6 e6 f6 g6 h6
                  a5 b5 c5 d5 e5 f5 g5 h5
                  a4 b4 c4 d4 e4 f4 g4 h4
                  a3 b3 c3 d3 e3 f3 g3 h3 
                  a2 b2 c2 d2 e2 f2 g2 h2 
                  a1 b1 c1 d1 e1 f1 g1 h1 )
                  

  # The file, aka column, labeled a-h, and stored as the ordinal of the letter
  attr_accessor :file 

  # The rank,  aka row ,  labeled 1-8, and stored as the ordinal of the rank
  attr_accessor :rank
  
  # Can be initialized with a symbol or a string representing a position such as d4
  def initialize(*args)
    if( args.length == 2)
      @file = args[0].to_s[0] - 96 # ascii a
      @rank = args[1].to_i 
    elsif( args.length == 1 )
      invalidate! and return unless args[0].to_s.length >= 2
      @file = args[0].to_s[0] - 96 # ascii a
      @rank = args[0].to_s[1].chr.to_i 
    end
  end
  
  #convenience for creating and calling to_sym on an instance of Position
  def self.as_symbol(*args)
    p = Position.new(args)
    p.to_sym
  end
  
  #returns a4, b8, etc..
  def to_s
    "#{(@file + 96).chr}#{rank}"
  end
  
  #returns a, b etc...
  def file_char
    (@file + 96).chr
  end
  
  #returns :a4, etc... or raises InvalidPositionError if not a vald position
  def to_sym
    raise InvalidPositionError unless valid?
    self.to_s.to_sym 
  end
  
  #determines whether this instance points to a valid position on the board
  def valid?
    POSITIONS.include?( self.to_s )
  end
  
  # Allows motion from one position to another, specified by a vector such as [1,0]
  # Returns a new position instance for the new position which may or may not be valid?
  def +(vector)
    newpos = Position.new( self.to_s )
    if vector.kind_of?(Array) and vector.length == 2 and vector[0].kind_of?(Fixnum) and vector[1].kind_of?(Fixnum)
      newpos.file += vector[1] 
      newpos.rank += vector[0]
    else
      newpos.send('invalidate!')
    end
    
    newpos #return
    
  end
  
  #B-A is the vector you must add to A to get to B, just as 4-1 yields the 3 you must add to 1 to get 4
  def -(other)
    return unless other.kind_of?(Position)
    return [ self.rank - other.rank, self.file - other.file ]
  end
  
private
  def invalidate!
    @file, @rank = [0,0]
  end
end

#While you may have an instance of the Position class referencing an invalid position (as a result of an add)
# for example, you must not try and convert it to a symbol, or look it up on a board, or you will get
# an InvalidPositionError. Thus the existance of the .valid? method on any position instance.
class InvalidPositionError < Exception
end
