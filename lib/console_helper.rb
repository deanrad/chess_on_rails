# Give us handy things in console like
# self.m = Match.find(N)
# move :a2, :a4
class Object
  def match;     @match; end
  def match= *args; @match = Match.find(*args); end
    
  # helper methods
  def move *args
    if args.length == 1
      match.moves << Move.new(:notation => args.shift.to_s)
    else
      match.moves << Move.new(:from_coord => args.shift.to_s, :to_coord => args.shift.to_s)
    end
    match.board
  end
  
  def chat msg
    match.chats << Chat.new( :player => match.white, :text => msg)
    msg
  end
end