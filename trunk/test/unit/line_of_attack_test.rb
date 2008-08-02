require File.dirname(__FILE__) + '/../test_helper'

class LineOfAttackTest < ActiveSupport::TestCase
  
  def test_line_of_attack_iterates_along_vector
    l = LineOfAttack.new( [1,1], 5 )
    l.each do |position|
      #puts "[#{position[0]},#{position[1]}]"
    end
  end

    
end
