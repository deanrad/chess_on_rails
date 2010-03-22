module San
  class San < Treetop::Runtime::SyntaxNode
    def initialize *args
      $stderr.puts "Loaded: #{self.text_value}"
      super
    end
  end

  module Move
    def piece
      # castling
      return :king unless self.respond_to?(:simple_move)
      if self.simple_move.respond_to?(:pawn_mover)
        :pawn
      else
        self.simple_move.non_pawn_mover.to_s[0..1]
      end
    end
  end
end

