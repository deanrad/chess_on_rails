require File.dirname(__FILE__) + '/../spec_helper'

describe 'Notation' do

  it 'should notate king K' do
    King.new.notation.upcase.should == 'K'
  end
  it 'should notate queen Q' do
    Queen.new.notation.upcase.should == 'Q'
  end
  it 'should notate rook R' do
    Rook.new.notation.upcase.should == 'R'
  end
  it 'should notate knight N' do
    Knight.new.notation.upcase.should == 'N'
  end
  it 'should notate bishop B' do
    Bishop.new.notation.upcase.should == 'B'
  end

  it 'should notate a pawn for the file it is on' do
    p = Pawn.new(:black)
    p.notation('b').should == 'b'
    p.notation('c').should == 'c'
  end

  it 'should not notate a pawn without its file' do
    p = Pawn.new
    lambda{ p.notation.should == 'p' }.should raise_error
  end

end
