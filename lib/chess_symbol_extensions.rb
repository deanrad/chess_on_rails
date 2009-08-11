module ChessSymbolExtensions
  def rank; @rank ||= self.to_s.rank ; end
  def file; @file ||= self.to_s.file ; end
  def back_rank
    @back_rank ||= case self
      when :white then '1'
      when :black then '8'
    end
  end
  def front_rank
    @front_rank ||= case self
      when :white then '2'
      when :black then '7'
    end
  end
  def castling_file
    @castling_file ||= case self
      when :queens then 'c'
      when :kings  then 'g'
    end
  end
  def opposite
    @opposite ||= case self
      when :white then :black
      when :black then :white
    end
  end
  # Lets you do d2 - d1 and get [0, -1]
  def - other
    self.to_s - other.to_s
  end
  # Lets you do d1 ^ [0, 1] and get d2
  def ^ other
    (self.to_s ^ other).to_sym
  end
end

Symbol.send(:include, ChessSymbolExtensions) unless Symbol.ancestors.include?(ChessSymbolExtensions)
