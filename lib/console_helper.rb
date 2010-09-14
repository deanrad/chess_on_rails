# Give us handy things in console like
# self.m = Match.find(N)
# move :a2, :a4
class Object
  def match;     @match; end
  def match= *args; @match = Match.find(*args); end
    
  # helper methods
  def move from, to
    match.moves << Move.new(:from_coord => from.to_s, :to_coord => to.to_s)
  end
end