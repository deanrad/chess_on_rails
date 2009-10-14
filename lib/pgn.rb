# Parses PGN files. My own quick dirty reinvention of the wheel.
# Note - the scanning regex produces some wierd results, thus the hack
# code needed in the initialize method. Heres what it looks like at runtime:
#>> "11. Ne2 Nd7 12. O-O".scan(NOTATION){ |n| puts n.to_a.inspect unless n.blank? }
# [nil, nil, nil, nil, nil, nil, nil, nil, nil]
# ["Ne2", "N", "", "", "e2", nil, "", nil, nil]
# ["Nd7", "N", "", "", "d7", nil, "", nil, nil]
# [nil, nil, nil, nil, nil, nil, nil, "O-O", nil]

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
    movetext.scan( NOTATION ) do |n|
      sorted_submatches = n.to_a.reject(&:nil?).uniq.sort{|a,b| a.length <=> b.length}
      @notations << sorted_submatches.last unless sorted_submatches.last.blank?
    end

    # $stderr.puts "PGN detected notations #{@notations.join(',')} in movetext:\n#{movetext}" 
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
      unless last_move.errors.blank?
        puts "PGN Error on notation: '#{notation}' " + last_move.errors.to_a.uniq.join(',')
        raise ArgumentError, last_move.errors.to_a 
        (@playback_errors ||= []) << last_move.errors.to_a.uniq
        break;
      end
    end
    match
  end

end
