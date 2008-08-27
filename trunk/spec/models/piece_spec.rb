require File.dirname(__FILE__) + '/../spec_helper'

describe Piece do
  
  before(:all) do
    @white_king  = King.new(:white)
    @black_queen= Queen.new(:black)
    @black_queens_bishop = Bishop.new(:black, :queens)
    @white_kings_knight = Knight.new(:white, :kings)
    @white_kings_rook = Rook.new(:white, :kings)
    @d_pawn = Pawn.new(:white, :d)
  end
  
  it 'must be affiliated with a side' do
    lambda{ piece = Piece.new(:king) }.should raise_error
  end
  
  it 'may be a king' do
    @white_king.role.should == :king
  end
  
  it 'may be a queen' do
    @black_queen.role.should == :queen
  end
  
  it 'may be a bishop' do
    @black_queens_bishop.kind_of?(Piece).should be_true
  end

  it 'may be a knight' do
    @white_kings_knight.kind_of?(Piece).should be_true
  end

  it 'may be a rook' do
    @white_kings_rook.kind_of?(Piece).should be_true
  end

  it 'may be a pawn' do
    @d_pawn.kind_of?(Piece).should be_true
  end

  it 'should tell you its desired moves (what it could do on an empty board) from a given position' do
    #desired_moves_from is a common interface to all pieces
    moves = Pawn.new(:white, :d).desired_moves_from( :d3 )
    #in this spec we just care that there are some moves
    moves.should have_at_least(1).item
  end
  
  it 'should not want to fall off the edge of the board' do
    Pawn.new(:white, :d).desired_moves_from( :f8 ).should be_empty
    Knight.new(:black, :d).desired_moves_from( :g8 ).should have(3).items
  end
  
  describe 'Abbreviations' do
    it 'should recognize Q as queen' do
      Piece.abbrev_to_role('Q').should == :queen
    end
  
    it 'should recognize K as king' do
      Piece.abbrev_to_role('K').should == :king
    end
  
    it 'should recognize B as bishop' do
      Piece.abbrev_to_role('B').should == :bishop
    end
  
    it 'should recognize N as knight' do
      Piece.abbrev_to_role('N').should == :knight
    end
  
    it 'should recognize R as rook' do
      Piece.abbrev_to_role('R').should == :rook
    end
  
    it 'should recognize a lower case letter as a pawn' do
      ('a'..'h').each do |letter|
        Piece.abbrev_to_role( letter ).should == :pawn
      end
    end
    
    it 'should abbreviate knight as N' do
      Piece.role_to_abbrev(:knight).should == 'N'
    end

    it 'should abbreviate all other non-pawn roles as their first letter' do
      [:king, :queen, :bishop, :rook].each do |role| 
        Piece.role_to_abbrev(role).should == role.to_s[0,1].upcase
      end
    end
  end
end
