# Give us handy things in console like
# self.m = Match.find(N)
# move :a2, :a4
class Object
    
  def match;     @match; end
  def match= *args; @match = args.first.kind_of?(Match) ? args.first : Match.find(*args); match.board; end

  def player;    @player; end
  def player= p;  @player = p.kind_of?(Fixnum) ? Player.find(p) : Player.find_by_name(p.to_s) ; p;  end
    
  # helper methods
  def move *args
    if args.length == 1
      match.moves << m=Move.new(:notation => args.shift.to_s)
    else
      match.moves << m=Move.new(:from_coord => args.shift.to_s, :to_coord => args.shift.to_s)
    end
    return match.reload.board if m.id
    return m.errors.full_messages
  end
  
  def chat msg
    match.chats << Chat.new( :player => match.white, :text => msg)
    msg
  end
  
  def reset
    self.match = Match.find(self.match.id)
  end
  
  def undo
    self.match.moves.last.destroy
    reset
  end
  
  def errors
    self.match.moves.last.errors.full_messages
  end
end