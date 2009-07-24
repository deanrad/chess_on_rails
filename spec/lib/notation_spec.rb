require File.dirname(__FILE__) + '/../spec_helper'

describe 'Notation' do

  it 'should notate king K' do
    King.new(:white).abbrev.upcase.should == 'K'
  end
  it 'should notate queen Q' do
    Queen.new(:white).abbrev.upcase.should == 'Q'
  end
  it 'should notate rook R' do
    Rook.new(:white).abbrev.upcase.should == 'R'
  end
  it 'should notate knight N' do
    Knight.new(:white).abbrev.upcase.should == 'N'
  end
  it 'should notate bishop B' do
    Bishop.new(:white).abbrev.upcase.should == 'B'
  end

  it 'should notate a pawn for the file it is on' do
    pending('havent found how to do this yet')
    p = Pawn.new(:black)
    p.notation('b').should == 'b'
    p.notation('c').should == 'c'
  end

  it 'should not notate a pawn without its file' do
    p = Pawn.new(:white)
    lambda{ p.notation.should == 'p' }.should raise_error
  end

end
