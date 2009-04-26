# Parses PGN files. My own quick dirty reinvention of the wheel.
class PGN
  attr_accessor :tags
  attr_accessor :notations

  NOTATION = /(([BKNPQR]?)([a-h1-8]?)(x?)([a-h][1-8])(=[BKNQR])?([+#]?))|(O-O(-O)?)/

  def initialize(str)
    @tags, @notations = [], []
    str.scan( NOTATION ) do |notation|
      @notations << notation[0]
    end
  end
end
