#extends the core objects in ways we can't help but to live with
class Array
  def count; length; end
end
class Hash
  def count; length; end
end
class NilClass
  def blank?; true; end
end
class String
  def blank?; self.length ==0; end
end
class Position
  def blank?; false; end  #if you have an instance to call this on, you're not blank
end
class Symbol
  def blank?; self.length ==0; end
  def length; self.to_s.length; end
end