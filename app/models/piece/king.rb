# The Daddy-O, move_directions :diagonal, :straight, :limit => 1
class King < Piece
  move_directions :diagonal, :straight, :limit => 1

  def initialize(side, discriminator=nil)
    super(side, :king, discriminator)
  end

  # Adds castling moves to the set of moves for which Piece#allowed_move? == true
  def allowed_moves(board)
    all_moves = super

    [:queens, :kings].each do |flank|
      if board.send("#{flank}ide_castle_available") && 
         board.castling_squares_empty?(self.side, flank)
         
         all_moves << "#{flank.castling_file}#{side.back_rank}".to_sym
      end
    end

    all_moves
  end
end
