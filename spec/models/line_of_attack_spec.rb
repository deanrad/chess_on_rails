require File.dirname(__FILE__) + '/../spec_helper'

describe LineOfAttack do
  
  it 'should iterate along a line of attack in a specified direction' do
    l = LineOfAttack.new( [1,1], 5 )
    l.each do |position|
      #puts "[#{position[0]},#{position[1]}]"
    end
  end

    
end
