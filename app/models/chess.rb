class Chess 	
  # The order of the ranks and files are very important. 
  # They are defined in layout order, and with white to move.
  RANKS  = %w{ 8 7 6 5 4 3 2 1 }
  FILES  = %w{ a b c d e f g h } 

  class << self
    extend ActiveSupport::Memoizable

    def setup_board(board)
      initial_pieces.each do |piece, pos|
        board[pos.to_sym] = piece
      end
    end

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

    def valid_position?(pos)
      all_positions.include? pos
    end

    def each_position( to_move = :white_to_move, order = :layout_order )
      all_positions(to_move, order).each { |p| yield p }
    end

    # Array of [piece, position] elements
    def initial_pieces
      
      @@pieces = []
      
      [ [:white, '1', '2'], [:black, '8', '7'] ].each do |side, back_rank, front_rank|
        ('a'..'h').each do |file|
          @@pieces << [ Pawn.new( side, file.to_sym) , file + front_rank ]
        end

        @@pieces << [ Rook.new(side, :queens)   , 'a'+back_rank ]
        @@pieces << [ Knight.new(side, :queens) , 'b'+back_rank ]
        @@pieces << [ Bishop.new(side, :queens) , 'c'+back_rank ]
        @@pieces << [ Queen.new(side )          , 'd'+back_rank ]
        @@pieces << [ King.new(side )           , 'e'+back_rank ]
        @@pieces << [ Bishop.new(side, :kings)  , 'f'+back_rank ]
        @@pieces << [ Knight.new(side, :kings)  , 'g'+back_rank ]
        @@pieces << [ Rook.new(side, :kings)    , 'h'+back_rank ]
      end

      @@pieces

    end # initial_pieces    

    memoize :ranks, :files, :all_positions, :valid_position?
  end # class << self  
end
