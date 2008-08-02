require File.dirname(__FILE__) + '/../spec_helper'

describe Piece do

  before(:all) do
    @k   = Piece.new( :king, :white )
    @wb  = Piece.new( :bishop, :white )
    @bq  = Piece.new( :queen, :black )
    @br  = Piece.new( :rook, :black, :queens )
    @wkb = Piece.new( :bishop, :white, :kings )
  end
  
  it 'can create pieces' do
    [@k, @wb, @wkb].each{ |p| assert_not_nil p }
  end
  
  it 'needs to know which for side id' do
    assert_raises AmbiguousPieceError do
      puts @wb.side_id
    end
  end
  
  it 'knows side id given sufficient information' do
    @wkb.side_id.should == :kings_bishop
  end
  
  it 'knows board id given sufficient information' do
    @bq.board_id.should == :black_queen
  end
  
  it 'bishop moves in any diagonal direction' do
    @wb.lines_of_attack.length.should == 4
    move_vectors = @wb.lines_of_attack.collect(&:vector)
    move_vectors.include?( [1,1] ).should be_true
    move_vectors.include?( [-1,1] ).should be_true
    move_vectors.include?( [1,-1] ).should be_true
    move_vectors.include?( [-1,-1] ).should be_true
  end
  
  it 'rook moves in any straight direction' do
    @br.lines_of_attack.length    .should == 4
    move_vectors = @br.lines_of_attack.collect(&:vector)
    [[1,0], [-1,0], [0,1], [0,-1]].each do |vector|
      move_vectors.include?(vector).should be_true
    end
  end

  it 'queen moves like bishop and rook combined' do
    @bq.lines_of_attack.length    .should == 8
  end
  
  #TODO fill out more tests for completeness and documentation sake
end
