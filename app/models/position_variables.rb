# any caller including this will have a1 a2 style local methods available to these positions
module PositionVariables
  def self.included(base)
    Position::FILES.each do |f|
      Position::RANKS.each do |r|
        base.class_eval "def #{f+r}; Position[:#{f+r}]; end"
      end
    end
  end
end
