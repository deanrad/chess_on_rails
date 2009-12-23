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
  attr_accessor_with_default :parsing_errors, []

  # errors occurring while trying to play back against a match
  attr_accessor_with_default :playback_errors, []

  # PGN text stripped of comments, event headers, etc.. Just the moves..
  attr_accessor :normalized_text

  NOTATION = /(([BKNPQR]?)([a-h1-8]?)(x?)([a-h][1-8])(=[BKNQR])?([+#]?))|(O-O(-O)?)/

  def initialize(str)
    @tags, @notations, @errors = [], [], {}

    unless PGN::is_pgn?(str)
      @errors[:format] = 'Invalid PGN file - The string 1. was not detected.' and return
    end

    @normalized_text = str.gsub("\r","").gsub( /^\s*\[.*?\]$\n?/, '').gsub( /\{.*?\}/m, '').gsub(/\s+/, " ")
    
    @normalized_text.scan( NOTATION ) do |n|
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

  # Given a match object presumably starting at the beginning, plays the moves on it
  # and returns the match. Caller should check for errors.
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

  # In addition to the fixtures named in matches.yml, we can refer to a pgn file in the 
  # test/fixtures/matches directory by specifying its name as a symbol 
  module Fixtures
    # Allows us to bring in PGN fixtures !!
    def matches_with_pgn_fixtures *args
      matches_without_pgn_fixtures *args
    rescue
      pgn = PGN.new( `cat #{RAILS_ROOT}/spec/fixtures/matches/#{args.first}.pgn` )
      pgn.playback_against( Match.new )
    end
    def self.included(base)
      base.class_eval {
        alias_method_chain :matches, :pgn_fixtures
      }
    end
  end

end

