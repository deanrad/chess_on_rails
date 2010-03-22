# The SanGrammar module, particularly its SanRoot class, adds an object-like
# layer on top of the parse tree returned when Treetop matches an instance 
# of San (Standard Algebraic Notation) notating a move.
module SanGrammar

  # Specializes the root of a parse tree of San to have properties. 
  # If the treetop object model returned from a parse were easier to
  # query I may not have added my methods this way, but it's fine since
  # it keeps callers simpler to abstract the tree structure away from them.
  class SanRoot < Treetop::Runtime::SyntaxNode
    # :kingside, :queenside, or nil if not a castling move
    def castle_side
      return nil unless move.castling?
      move.text_value.length == 3 ? :kingside : :queenside
    end
    def castle?;  !!castle_side   ;end

    # The piece involved in the move, as a symbol, :king for castling
    def piece
      return :king if move.castling?
      return :pawn unless move.respond_to?(:non_pawn_mover)
      SAN::ABBREV_TO_ROLE[ move.non_pawn_mover.text_value.first ]
    end

    # True/false - whether a capture occurred, even enpassant
    def capture?
      self.text_value.include? 'x'
    end

    # The destination square as a string. Nil for castling moves since the San
    # doesn't tell us which side made the move !
    def destination
      return nil if castle? 
      move.destination.text_value
    end

    # The piece role chosen for promotion, as a symbol
    def promo
      return nil unless (p=move.elements.last).promotion?
      SAN::ABBREV_TO_ROLE[ p.text_value.last ]
    end

    # True/false- if this San notates a check
    def check?
      threat.text_value=="+"
    end

    # True/false- if this San notates a checkmate
    def mate?
      threat.text_value=="#"
    end
  end

end

# Here I add some generic methods to SyntaxNode (dangerous!)
# I really wish I could have named access to treetop nodes returned
# Here are some tricks which rely on the fact that anonymous modules 
# are created whose name match the rules I'm interested in testing
class Treetop::Runtime::SyntaxNode
  # Example: <SyntaxNode+SimpleMove0>.matched_by('simple_move?') => true
  def matched_by? str
    m = Regexp.new( "::#{str.classify}\\d+")
    ! self.extension_modules.map(&:to_s).grep( m ).empty?
  end

  # Allows .castling? to delegate to matched_by('castling') so I can query
  # if a node is a match due to a certain rule
  def method_missing(name, *args)
    case n=name.to_s
    when /\w+\?/
      self.matched_by?( n.sub( /\?$/, '' ) )
    else
      super
    end
  end
end
