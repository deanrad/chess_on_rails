# The base class of all pieces - contains behaviors common to all pieces
class Piece  

  attr_accessor :side 
  attr_accessor :function
  attr_accessor :discriminator # eg queens, kings, promoted, a, b (for pawns)

  class << self
    attr_accessor :move_vectors, :moves_unlimited
  end

  # Allows a subclass to declare its moves
  # These are stored in instance variables on the class invoking this
  # Example:  move_directions :straight, :limit => none
  # http://martinfowler.com/bliki/ClassInstanceVariable.html
  def self.move_directions(*args)
    @move_vectors = args.include?(:straight) ? [[1,0],[-1,0],[0,1],[0,-1]] : []
    @move_vectors.concat( [[1,1],[-1,1],[1,-1],[-1,-1]] ) if args.include?(:diagonal)
    @moves_unlimited = args.last[:limit]==:none
  end

  def initialize(side, function, discriminator=nil)
    @side, @function, @discriminator = side, function, discriminator
  end

  # default implementation, has no knowledge of capturability
  def self.allowed_move?(vector, starting_rank = nil)
    return false if vector == [0,0] #cant move to self
    return move_vectors.include?(vector) unless moves_unlimited

    likely_vector = move_vectors.detect do |mv| 
      mv[0].sign == vector[0].sign  && mv[1].sign == vector[1].sign 
    end

    return likely_vector != nil
    #move_vectors.each do |dir|
    #  1.upto(8).each do |multiple|
    #    return true if vector == [ dir[0]*multiple, dir[1]*multiple ]
    #  end
    #end
    # return false
  end

  
  # gives instances access to the class method, but allow child classes to override
  def allowed_move?(vector, starting_rank=nil)
    self.class.allowed_move?(vector, starting_rank)
  end

  # the set of squares on the board for which this piece answers allowed_move? == true
  def allowed_moves(board)
    #quick dirty attempt at memoization
    @moves_cache ||= {}
    return @moves_cache[board] if @moves_cache[board]

    mypos = board.index(self) 

    returning( moves = [] ) do
      board.each_square do |sq|
        moves << sq.to_sym if allowed_move?( sq - mypos, mypos.rank ) && !obstructed?( board, mypos, sq - mypos )
      end
      @moves_cache[board] = moves
    end
  end

  # Answers "Am I forbidden to move from [mypos] to the position specified by [vector], on this board" ?
  # Returns yes when blocked by your own piece, etc..
  # - No piece can obstruct a knight move
  # - A pawns sideways move is obstructed by space or his own side
  # - We walk along a piece's attack-line looking for obstructions
  # - If you hit a piece along the attack-line, but not at the end, you're blocked
  # - At the end of the attack-line, you're blocked only if by your own piece
  def obstructed?( board, mypos, vector )

    return false if @function==:knight

    if @function==:pawn && vector[0] != 0 
      dest_piece = board[ mypos ^ vector ]
      return true unless dest_piece && dest_piece.side != self.side
    end

    vector.walk do |step|
      if dest_piece = board[ mypos ^ step ]
        return step != vector || dest_piece.side == self.side
      end
    end
    
    return false
  end

  # when rendered the client id uniquely specifies an individual piece within a board
  # example: f_pawn_w
  def board_id
    dtag = @discriminator ? @discriminator.to_s[0,1]+'_':''
    "#{dtag}#{self.img_name}"
  end

  # a combination of the function (role) and side
  def img_name
    "#{@function}_#{@side.to_s[0,1]}"
  end
    
  # for FEN like situations
  def abbrev
    letter = case @function 
      when :pawn then 'p' 
      when :knight then 'n'
      else @function.to_s[0,1]
    end
    return letter.send( @side==:white ? :upcase : :downcase )
  end

end

