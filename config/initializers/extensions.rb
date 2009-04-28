####### helper functions #########

class Object
  # convenience syntax
  def with(arg)
    yield arg
  end
end

#for ruby < 1.9 to use ruby 1.9 each_char unicode safe syntax
class String
  def each_char
    (0..self.length-1).each { |place| yield self[place..place] }
  end
  def rank
    self[1..1].to_i
  end

  # Lets you do d2 - d1 and get [0, -1]
  def - other
    [ self[0] - other[0], self[1] - other[1] ]
  end

  # Lets you do d1 ^ [0, 1] and get d2
  def ^ vector
    file, rank = (self[0]+vector[0]).chr, (self[1]+vector[1]).chr
    "#{file}#{rank}"
  end
end
