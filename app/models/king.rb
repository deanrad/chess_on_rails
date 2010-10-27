# The Daddy-O, move_directions :diagonal, :straight, :limit => 1
class King < Piece
  move_directions :diagonal, :straight, :limit => 1
  POINT_VALUE='∞'
  def initialize(side, discriminator=nil)
    super(side, :king, discriminator)
  end

  # Adds castling moves to the set of moves for which Piece#allowed_move? == true
  def special_moves(board)
    [:queen, :king].inject([]) do |all_moves, flank|
      next all_moves unless board.send("#{self.side}_can_castle_#{flank}side")
      next all_moves if flank.castling_files.inject do |occupied, file| 
        occupied &&= board[ :"#{file}#{self.side.back_rank}" ]
      end
         
      all_moves << :"#{flank.castling_file}#{side.back_rank}"
    end
  end

end
