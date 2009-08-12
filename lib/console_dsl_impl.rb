module ConsoleDslImpl
  def self.included(base)
    help_msg =<<"EOF"
    
To use this console, first select a match:
  >> set match 3

Then make moves
  >> a2  #or Nc3, etc...
    
And enjoy !!

EOF
    puts help_msg
    
    # put handlers in place to allow arbitrary typing of moves at the prompt
    base.instance_eval do
      # for initial capital letter notation moves Nc4
      def const_missing(name)
        puts "Eventually we will handle this, and it'll be beautiful, but for now... "
        move name
      end
      # see later in the module where the method_missing definition is more normally pulled in
    end

  end

  ######## user interaction methods #########
  def current_match
    $current_match
  end
  def current_match= m
    $current_match = m
  end
  
  def set match
    self.current_match = match
    puts current_match.board.to_s
  end

  # returns the 
  def match ident
    case ident
      when Fixnum, Symbol
        Match.find(ident)
      when String
        Match.find_by_name(ident)
    end
  end

  def show
    puts @current_match.board.to_s
  end

  ######## methods to allow notation typing #########
  # delegate things typed to the move method
  #def method_missing(name, *args)
    #super unless name.grep(/[1-8]/)
  #  move name
  #end

  # returns a lambda to be called in the scope of the caller ???
  def move name
    puts "So you want to move to #{name}, eh ? Sorry, this feature not programmed / in experimental mode.. Soon though.. "
    puts "There is no current match! Type set match 3 or similar to establish a current match" and return unless current_match
    puts "Moving to #{name}..."
    current_match.moves << Move.new(:notation => name)
    puts current_match.board.to_s
  end

end
