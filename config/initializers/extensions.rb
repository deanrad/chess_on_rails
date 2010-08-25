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

class String
  def method_missing name, *args
    if self.to_sym.respond_to? name
      self.to_sym.send(name, *args)
    else
      raise NoMethodError
    end
  end

end

class Symbol
  def file; self.to_s[0..0]       ; end
  def rank; self.to_s[1..1].to_i  ; end

  def flank;          %w{a b c d}.include?( self.file ) ? :queen : :king ; end
  def castling_files; self == :queen ? %w{b c d} : %w{ f g }             ; end
  def castling_file;  self == :queen ? :c : :g                           ; end
  def back_rank;      self == :white ? 1 : 8                             ; end
  def opposite;       self == :black ? :white : :black                   ; end
  
  # Lets you do d2 - d1 and get [0, -1]
  def - other
    [ to_s[0] - other.to_s[0], to_s[1] - other.to_s[1] ]
  end

  # Lets you do d1 ^ [0, 1] and get d2
  def ^ vector
    file, rank = (to_s[0]+vector[0]).chr, (to_s[1]+vector[1]).chr
    "#{file}#{rank}".to_sym
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


module MyModuleMethodIntrospection
  def methods_excluding_ancestors
    (self.instance_methods - (self.included_modules.map(&:instance_methods).reduce(&:+) || []) ).sort
  end
end
Module.send(:include, MyModuleMethodIntrospection)
