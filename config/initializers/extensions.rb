####### helper functions #########

# An alternate syntax is to 'opening' up the class is to define a module and then
# Object.send(:include, MyCoolModule)

class Object
  # convenience syntax
  def with(arg)
    yield arg
  end

  def try(meth, *args)
    self.send(meth, *args) if self.respond_to?(meth)
  end
end

#for ruby < 1.9 to use ruby 1.9 each_char unicode safe syntax
class String
  def each_char
    (0..self.length-1).each { |place| yield self[place..place] }
  end

  # Lets you do d2 - d1 and get [0, -1]
  def - other
    [ self[0] - other[0], self[1] - other[1] ]
  end

  # Lets you do d1 ^ [0, 1] and get d2 (basic vector addition)
  def ^ vector
    file, rank = (self[0]+vector[0]).chr, (self[1]+vector[1]).chr
    "#{file}#{rank}"
  end
end

class Fixnum
  def sign; self == 0 ? 0 : self < 0 ? -1 : 1 ; end
end

class Array
    # the basis vector - [1,1] for [n, n] [-1, 0] for [-n, 0]
  def basis
    self.map{|comp| comp.sign }
  end

  # for [3,0] yields [1,0], [2,0], and [3,0] in succession
  # for [2,2] yields [1,1], and [2,2] in succession
  def walk
    1.upto( self.map(&:abs).max ) do |mult|
      yield [ basis[0] * mult, basis[1] * mult ]
    end
  end

end

########## Chess specific patches follow #########
class String

  # black for a1 and b2, white for a8, etc..
  def square_color
    offset = (self[0]+self[1]) % 2
    offset == 0 ? :black : :white
  end

  def rank
    self[1..1].to_i
  end

  def file
    self[0..0]
  end

end # end monkeypatch String

class Symbol

  def rank; @rank ||= self.to_s.rank ; end
  def file; @file ||= self.to_s.file ; end
  def back_rank
    @back_rank ||= case self
      when :white then '1'
      when :black then '8'
    end
  end
  def front_rank
    @front_rank ||= case self
      when :white then '2'
      when :black then '7'
    end
  end
  def castling_file
    @castling_file ||= case self
      when :queens, :queenside then 'c'
      when :kings,  :kingside  then 'g'
    end
  end
  def opposite
    @opposite ||= case self
      when :white then :black
      when :black then :white
    end
  end

  # Lets you do d2 - d1 and get [0, -1]
  def - other
    self.to_s - other.to_s
  end
  # Lets you do d1 ^ [0, 1] and get d2 (basic vector addition)
  def ^ other
    (self.to_s ^ other).to_sym
  end

  alias :to_s_const :to_s
  # Avoid creating String garbage objects when
  # needing a read-only String representation of a Symbol.
  def to_s_const
    @to_s_const ||= to_s.freeze
  end

end
