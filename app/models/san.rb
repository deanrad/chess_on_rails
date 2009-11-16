# An instance of Standard Algebraic Notation
class SAN

  # The regular expression for parsing a SAN string (a work-in-progress!)
  REGEXP = /(?:([RNBQK]|[a-h](?=x))?([a-h1-8])*?(x)?([a-h][1-8])(=([RNBQ]))?([+?!\#])?|(O-O(?:-O)?))/


  # A map of roles (rook, knight, etc) to their abbreviations
  ROLE_TO_ABBREV = {:rook => "R", :knight => "N", :bishop => "B", :queen => "Q", :king => "K" }.freeze

  # A map of abbrevations to roles, also mapping a-h to pawn.
  ABBREV_TO_ROLE = ROLE_TO_ABBREV.invert.update( 
     %w( a b c d e f g h ).inject({}){|h,k| h[k] = :pawn; h } 
  ).freeze

  attr_accessor :original_text
  attr_accessor :role, :disambiguator, :capture, :destination, :promo, :qualifier, :castle, :castle_side

  # Mimics String.scan to return an array of instances of SAN for each SAN::REGEXP match in str.
  def self.scan(str) 
    returning(Array.new) do |matches|
      str.gsub(REGEXP){|m| matches.unshift self.new(m) }
    end
  end

  # Creates a SAN from a string
  def initialize(str)
    self.original_text = str

    if m = REGEXP.match(str)
      @role         =    m[1] 
      @disambiguator=    m[2]
      @capture      = !! m[3]
      @destination  =    m[4]
      @promo        =    m[6]
      @qualifier    =    m[7]
      @castle       = !! m[8]
      @castle_side  =    m[8].length > 3 ? :queenside : :kingside    if m[8]

      if @destination && @role.blank?
        @role = :pawn 
      else
        @role = ABBREV_TO_ROLE[ @role ]
      end

      @promo = ABBREV_TO_ROLE[ @promo ]

    else
      $stderr.puts "SAN::Unrecognized notation #{str}"
    end
  end

  # Returns the SAN for the move passed
  def self.from_move(m)
    returning("") do |n|
      if m.castled
        return "O-O" if m.to_coord.file == "g"
        return "O-O-O" if m.to_coord.file == "c"
      end

      if m.piece.function == :pawn
        n << m.from_coord.file if m.capture?
      else
        n << ROLE_TO_ABBREV[m.piece.function]
      end

      # Move#capture? only returns true for moves that populate the captured_piece_coord
      if m.capture?
        n << "x"
      end

      n << "#{m.to_coord}"
      
      if m.promotion_choice
        n << "=#{m.promotion_choice}"
      end

    end
  end

  # Whether this instance notates that check occurred
  def check?; @check ||= !!(@qualifier =~ /[+#]/); end
end
