Board.class_eval do
  # bring in the ability to notate boards as Forsyth-Edwards notation
  include Fen

  # Two boards hash to the same value if their fen strings are identical.
  def hash
    self.to_fen.hash
  end
end
