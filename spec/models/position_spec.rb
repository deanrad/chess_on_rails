require File.dirname(__FILE__) + '/../spec_helper'

describe Position do

  include PositionVariables

  it 'a1 through h8 are valid positions' do
    ('a'..'h').each do |file|
      ('1'..'8').each do |rank|
        eval( "#{file}#{rank}" ).should be_kind_of(Position)
      end
    end
  end

  it 'a1 rank should be 1' do
    a1.rank.should == 1
  end

  it 'a1 file should be a' do
    a1.file.should == 'a'
  end

  it 'rejects invalid positions' do
    ['xyz', '', nil, 'a9'].each do |bad_one|
      lambda{ p = Position[bad_one]}.should raise_error(InvalidPositionError)
    end
  end

  it 'a1 color should be :black' do
    a1.color.should == :black
  end

  it 'a2 should be on diagonal from b3' do
    a2.diagonal_from?( b3 ).should be_true
  end

  it 'a2 should be one diagonal space from b3' do
    a2.diagonal_spaces_to( b3 ).should == 1
  end

  it 'b3 should be one diagonal space from a2' do
    a2.diagonal_spaces_to( b3 ).should == 1
  end

  it 'c5 should be across from c7' do
    c5.across_from?( c7 ).should be_true
  end

end
