# An instance of Standard Algebraic Notation
class SAN
  REGEXP = /([RNBQK]|[a-h](?=x))?(x)?([a-h][1-8])(=([RNBQ]))?([+?!\#])?/

  attr_accessor :original_text
  attr_accessor :role, :capture, :destination, :promo, :qualifier, :annotation  # "

  # Mimics String.scan to return an instance of SAN for each SAN::REGEXP match in str.
  def self.scan(str) 
    matches = str.scan REGEXP
    # $stderr.puts matches.inspect
    matches.map{|m| self.new(m) }
  end

  # Lets you pass a string, or array of parts [@role, @capture, @destination, @promo, @qualifier, @annotation]
  def initialize(str_or_matches)
    if Array === str_or_matches
      @role, @capture, @destination, @promo, @qualifier, @annotation = *str_or_matches
      return
    end
    self.original_text = str

    if m = REGEXP.match(str)
      @role         = m.groups[1] 
      @capture      = !! m.groups[2]
      @destination  = m.groups[3]
      @promo        = m.groups[5] || nil
      @qualifier    = m.groups[6] || nil

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

      $stderr.puts "SAN::Created San object from #{str}: #{self.inspect}"
    else
      $stderr.puts "SAN::Unrecognized notation #{str}"
    end
  end

  # Whether this instance notates that check occurred
  def check?; @check ||= !!(@qualifier =~ /\+/); end
end
