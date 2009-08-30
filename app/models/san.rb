# An instance of Standard Algebraic Notation
class SAN
  REGEXP = /(?:([RNBQK]|[a-h](?=x))?([a-h1-8])*?(x)?([a-h][1-8])(=([RNBQ]))?([+?!\#])?|(O-O(?:-O)?))/

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
        @role = case @role
          when "R"; :rook
          when "N"; :knight
          when "B"; :bishop
          when "Q"; :queen
          when "K"; :king
          when "a","b","c","d","e","f","g","h"; :pawn
        end
      end

      @promo = case @promo
        when "R"; :rook
        when "N"; :knight
        when "B"; :bishop
        when "Q"; :queen
        when "K"; :king
      end

    else
      $stderr.puts "SAN::Unrecognized notation #{str}"
    end
  end

  # Whether this instance notates that check occurred
  def check?; @check ||= !!(@qualifier =~ /[+#]/); end
end
