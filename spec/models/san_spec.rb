require 'spec/spec_helper'

describe 'San' do
  before(:all) do
    @parser = Treetop.load('lib/san').new
    @valid_sans = %w{
    O-O
    O-O-O 
    a4
    dxe4
    Ne4
    Nxc6
    Rae4
    R1xb6
    axd8=Q
    Rd8+
    Qxf7#
    d8=Q+
    f7!!
    Qxa4?
  }
  end
  
  it 'should recognize most notations' do
    unrecognized = @valid_sans.select do |n|
      @parser.parse(n).nil?
    end

    unrecognized.should == []
  end

 end
