require 'spec/spec_helper'

describe 'SAN' do

  describe 'created from a move' do
    it 'should notate a capture with an x' do
      m = Move.new(:to_coord => 'c3')
      m.stubs(:capture?).returns(true)
      m.stubs(:piece).returns( Knight.new(:white) )
      SAN.from_move(m).should == 'Nxc3'
    end

    it 'should notate non-capturing knight move as Nc3' do
      m = Move.new(:to_coord => 'c3')
      m.stubs(:piece).returns( Knight.new(:white) )
      SAN.from_move(m).should == 'Nc3'
    end

    describe '- pawn moves -' do
      describe 'a forward-only move' do
        it 'should be notated just by the destination' do
          m = Move.new(:from_coord => 'd2', :to_coord => 'd4')
          m.stubs(:piece).returns( Pawn.new(:white, :d) )
          SAN.from_move(m).should == 'd4'
        end
      end
      describe 'a capturing move' do
        it 'should be notated by the from coordinate, an x, and the destination' do
          m = Move.new(:from_coord => 'd4', :to_coord => 'e5')
          m.stubs(:piece).returns( Pawn.new(:white, :d) )
          m.stubs(:capture?).returns(true)
          SAN.from_move(m).should == 'dxe5'
        end
      end
      describe 'en passant capture' do
        it 'should be notated by the from coordinate, an x, and the destination' do
          m = Move.new(:from_coord => 'd5', :to_coord => 'e6')
          m.stubs(:piece).returns( Pawn.new(:white, :d) )
          m.stubs(:capture?).returns(true)
          SAN.from_move(m).should == 'dxe6'
        end
      end
    end

    describe 'castling' do
      it 'should notate a kingside castle as O-O' do
        m = Move.new(:from_coord => 'e1', :to_coord => 'g1')
        m.stubs(:board).returns( Board.new.delete_if{|k,v| [:f1, :g1].include?(k) } )
        m.update_computed_fields
        m.castled.should == 1
        SAN.from_move(m).should == "O-O"
      end
    end
  end # describe 'created from a move'

  describe 'parsed from a string' do
    describe 'd4' do
      before(:all){ @san = SAN.new('d4') }

      it 'should know a pawn is the mover' do
        @san.role.should == :pawn
      end
      it 'should know d4 is the destination' do
        @san.destination.should == 'd4'
      end
      it 'should know it was not a capture' do
        @san.capture.should be_false
      end
    end
  end
end
