# Parses PGN files. My own quick dirty reinvention of the wheel.
class PGN
  attr_accessor :tags
  attr_accessor :notations

  # errors in the text
  attr_accessor :errors

  # errors occurring while trying to play back against a match
  attr_accessor :playback_errors

  NOTATION = /(([BKNPQR]?)([a-h1-8]?)(x?)([a-h][1-8])(=[BKNQR])?([+#]?))|(O-O(-O)?)/

  def initialize(str)
    @tags, @notations, @errors = [], [], {}

    unless PGN::is_pgn?(str)
      @errors[:format] = 'Invalid PGN file - The string 1. was not detected.' and return
    end

    movetext = str #TODO split off the movetext section alone for parsing
    movetext.scan( NOTATION ) do |notation|
      @notations << notation[0]
    end

    @errors[:moves] = 'No moves were detected in this PGN file.' unless @notations.length > 1
  end

  # Primitive implementation of pgn detection
  def self.is_pgn?( str )
    str.include?('1.')
  end

  def valid?
    @errors.empty?
  end

  # Given an initialized match object, replays the moves
  def playback_against( match )
    last_move = nil
    notations.each do |notation|
      match.moves << last_move = Move.new( :notation => notation )
      unless last_move.valid?
        # raise ArgumentError, last_move.errors.to_a 
        @playback_errors = last_move.errors
        break;
      end
    end
  end

end
