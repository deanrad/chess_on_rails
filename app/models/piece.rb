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

    move_vectors.each do |dir|
      1.upto(8).each do |multiple|
        return true if vector == [ dir[0]*multiple, dir[1]*multiple ]
      end
    end
    return false
  end

  # gives instances access to the class method, but allow child classes to override
  def allowed_move?(vector)
    self.class.allowed_move?(vector)
  end

  def position_on(board)
    board.index(self)
  end

  def allowed_moves(board)
    #LEFTOFF - must lookup position of this piece, convert sqaures to vectors, etc..
    mypos = position_on(board)
    returning( moves = [] ) do
      board.each_square do |sq|
        moves << sq.to_sym if allowed_move?( sq - mypos, mypos.rank ) && !obstructed?( board, mypos, sq - mypos )
      end
    end
  end

  # Am I forbidden to move from mypos to the position specified by vector, on this board ? 
  # Returns yes for such situations as - intervening pieces, blocked by your own piece, etc..
  def obstructed?( board, mypos, vector )
    dest_piece = board[ mypos ^ vector ]

    # a pawns sideways move is obstructed by space or his own side
    if @function==:pawn && vector[0].abs != 0 
      return true unless dest_piece && dest_piece.side != self.side
    end

    # no piece can obstruct a one-unit move or less (except for pawns, above), or a knight move
    return false if @function==:knight || vector.map(&:abs).max <= 1

    # TODO do interpolation
    return false

  end

  # when rendered the client id uniquely specifies an individual piece within a board
  # example: f_pawn_w
  def board_id
    dtag = @discriminator ? @discriminator.to_s[0,1]+'_':''
    "#{dtag}#{@function}_#{@side.to_s[0,1]}"
  end

  # a combination of the side and function
  def img_name
    "#{@function}_#{@side.to_s[0,1]}"
  end
    

end

