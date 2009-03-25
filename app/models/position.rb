class InvalidPositionError < RuntimeError; end

class Position

  attr_accessor :file, :rank
  def initialize( file, rank )
    self.file = file
    self.rank = rank
  end
  private :initialize

  FILES = 'a'..'h'
  RANKS = '1'..'8'

  @@valid_positions = {}
  FILES.each do |f|
    RANKS.each do |r|
      @@valid_positions.store( :"#{f+r}", Position.new(f, r.to_i) )
    end
  end

  def self.[]( pos )
    position = case 
      when pos.kind_of?(Symbol)
        @@valid_positions[pos]
      when pos.kind_of?(String) && pos!= ''
        @@valid_positions[pos.to_sym]
    end
    raise InvalidPositionError, pos unless position
    position
  end

  # a1 is black, a8 is white 'white on right rule', colors alternate
  def color
    (self.file[0] + self.rank) % 2 == 0 ? :black : :white
  end

  def diagonal_spaces_to( other )
    file_diff = other.file[0] - self.file[0] #works as long as "a"[0] returns the char code
    rank_diff = other.rank - self.rank
    rank_diff.abs == file_diff.abs ? file_diff.abs : nil
  end
  # memoize diagonal_spaces_to

  def diagonal_from?( other )
    !! diagonal_spaces_to( other )
  end

  def across_spaces_to( other )
    file_diff = other.file[0] - self.file[0] #works as long as "a"[0] returns the char code
    rank_diff = other.rank - self.rank
    return nil unless rank_diff * file_diff == 0
    return rank_diff == 0 ? file_diff.abs : rank_diff.abs
  end
  # memoize across_spaces_to

  def across_from?( other )
    !! across_spaces_to( other )
  end

  def to_s;    self.pos.to_s; end
  def inspect; self.to_s;     end

end
