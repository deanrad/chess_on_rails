require File.dirname(__FILE__) + '/../spec_helper'

describe 'Piece' do

  it 'should have an image name made of function and color' do
    Rook.new(:black, :queens).img_name.should == 'rook_b'
    Piece.new(:white, :pawn, :c).img_name.should == 'pawn_w'
  end	

  it 'should have a board id made of function and color and discriminator' do
    Piece.new(:white, :pawn, :c).board_id.should == 'c_pawn_w'
    Rook.new(:black, :queens).board_id.should    == 'q_rook_b'
  end	

  describe 'Move Directions' do
    it 'king can move one in any direction' do
      King.allowed_move?( [0,1] ).should be_true
    end

    it 'king can not move more than one in any direction' do
      King.allowed_move?( [0,2] ).should be_false
    end

    it 'king can not move more than one in any direction (instance version)' do
      k = King.new(:white)
      k.allowed_move?( [0,2] ).should be_false
    end

    it 'queen can move one in any direction' do
      Queen.allowed_move?( [1,0] ).should be_true
    end

    it 'queen can move in long straight lines' do
      Queen.allowed_move?( [3,3] ).should be_true
    end

    it 'queen cant move like knight' do
      q = Queen.new(:black)
      Queen.allowed_move?( [2,-1] ).should be_false
    end
    
  end

  describe 'Piece Types' do
    it 'white pawn can move forward two from its home rank' do
      p = Pawn.new(:white)
      p.allowed_move?( [0, 2], 2).should be_true
    end

    it 'white pawn can not move forward two beyond its home rank' do
      p = Pawn.new(:white)
      p.allowed_move?( [0, 2], 4).should be_false
    end

    it 'white pawn can move forward-diagonal one unit' do
      p = Pawn.new(:white)
      p.allowed_move?( [1, 1], 2).should be_true
    end

    it 'black pawn can move forward two from its home rank' do
      p = Pawn.new(:black)
      p.allowed_move?( [0, -2], 7).should be_true
    end

    it 'white pawn can not move forward two beyond its home rank' do
      p = Pawn.new(:white)
      p.allowed_move?( [0, -2], 5).should be_false
    end

    it 'knight can move 2 and 1 units' do
      k = Knight.new(:black)
      k.allowed_move?( [1, -2] ).should be_true
    end
  end

  describe 'Allowed move examples' do
    it 'should count bishops moves after 1. e4 correctly' do
      Board.any_instance.stubs('in_checkmate?').returns false
      Board.any_instance.stubs('in_check?').returns false

      m = matches(:unstarted_match)
      m.moves << Move.new(:from_coord => 'e2', :to_coord => 'e4')

      m.board[:f1].allowed_moves(m.board).should == [:a6, :b5, :c4, :d3, :e2]
    end

    it 'should raise exception if allowed_moves called with no board' do
      p = matches(:unstarted_match).board[:d4]
      p.stubs(:board).returns(nil)
      lambda{ p.allowed_moves }.should raise_error
    end

  end
end
