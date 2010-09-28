class Chess 	
  # The ranks, or rows, defined in layout order, with white to move.
  RANKS  = %w{ 8 7 6 5 4 3 2 1 }

  # The files, or columns, defined in layout order, with white to move.
  FILES  = %w{ a b c d e f g h } 

  # The squares involved in an opening up an enpassant square
  EN_PASSANT = {:white => [2,3,4], :black => [7,6,5] }

  class << self
    extend ActiveSupport::Memoizable

    def ranks( to_move = :white, order = :layout_order )
      to_move == :white ? RANKS : RANKS.reverse
    end

    def files( to_move = :white, order = :layout_order )
      to_move == :white ? FILES : FILES.reverse
    end

    def all_positions( to_move = :white_to_move, order = :layout_order )
      positions = []
      first_by, then_by = RANKS, FILES
      then_by.each do |outer|
        first_by.each  do |inner|
          file, rank = (first_by == RANKS  ? [outer, inner] : [inner, outer])
          positions << "#{file}#{rank}".to_sym
        end
      end
      positions
    end

    def valid_position? pos
      !pos.nil? && all_positions.include?(pos.to_sym)
    end

    def each_position to_move = :white_to_move, order = :layout_order 
      all_positions(to_move, order).each { |p| yield p }
    end

    # Array of [piece, position] elements
    def new_board
      Board[
        *(
          [
           :a1 , Rook.new(:white, :queens),   
           :b1 , Knight.new(:white, :queens),
           :c1 , Bishop.new(:white, :queens),
           :d1 , Queen.new(:white),
           :e1 , King.new(:white),           
           :f1 , Bishop.new(:white, :kings),
           :g1 , Knight.new(:white, :kings), 
           :h1 , Rook.new(:white, :kings), 
          ] +
          [
           :a8 , Rook.new(:black, :queens),   
           :b8 , Knight.new(:black, :queens),
           :c8 , Bishop.new(:black, :queens),
           :d8 , Queen.new(:black),
           :e8 , King.new(:black),           
           :f8 , Bishop.new(:black, :kings),
           :g8 , Knight.new(:black, :kings), 
           :h8 , Rook.new(:black, :kings), 
          ] +
          [
           :a2 , Pawn.new(:white, :a),
           :b2 , Pawn.new(:white, :b),
           :c2 , Pawn.new(:white, :c),
           :d2 , Pawn.new(:white, :d),
           :e2 , Pawn.new(:white, :e),
           :f2 , Pawn.new(:white, :f),
           :g2 , Pawn.new(:white, :g),
           :h2 , Pawn.new(:white, :h),
          ] + 
          [
           :a7 , Pawn.new(:black, :a),
           :b7 , Pawn.new(:black, :b),
           :c7 , Pawn.new(:black, :c),
           :d7 , Pawn.new(:black, :d),
           :e7 , Pawn.new(:black, :e),
           :f7 , Pawn.new(:black, :f),
           :g7 , Pawn.new(:black, :g),
           :h7 , Pawn.new(:black, :h),
          ]
        )
       ]
    end # initial_pieces

    memoize :ranks, :files, :all_positions, :valid_position?
  end # class << self  
end
