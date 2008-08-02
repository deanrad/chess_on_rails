# Position represents one of the squares of the board
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
    #raise InvalidPositionError, "#{args.join(',')} did not specify a valid position" unless valid?
  end
  
  #convenience for creating and calling to_sym on an instance of Position
  def self.as_symbol(*args)
    p = Position.new(args)
    p.to_sym
  end
  
  def to_s
    "#{(@file + 96).chr}#{rank}"
  end
  
  def to_sym
    raise InvalidPositionError unless valid?
    self.to_s.to_sym 
  end
  
  def valid?
    POSITIONS.include?( self.to_s )
  end
  
  # Allows adding to rank and file ala  +@a5 += [1,0]+
  def +(vector)
    newpos = Position.new( self.to_s )
    if vector.kind_of?(Array) and vector.length == 2 and vector[0].kind_of?(Fixnum) and vector[1].kind_of?(Fixnum)
      newpos.file += vector[1] #note reversal
      newpos.rank += vector[0]
    else
      newpos.send('invalidate!')
    end
    
    newpos #return
    
  end
  
private
  def invalidate!
    @file, @rank = [0,0]
  end
end

class InvalidPositionError < Exception
end
