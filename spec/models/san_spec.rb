require 'spec/spec_helper'

require 'san_node_classes'

describe 'San (Treetop version, in development)' do
  before(:all) do
    @parser = Treetop.load('lib/san').new
    @sans = [
    ['O-O',   :king,   nil],
    ['O-O-O', :king,   nil],
    ['a4',    :pawn,   'a4'],
    ['dxe4',  :pawn,   'e4'],
    ['Bh8',   :bishop, 'h8'],
    ['Nxc6',  :knight, 'c6'],
    ['Rae4',  :rook,   'e4'],
    ['R1xb6', :rook,   'b6'],
    ['axd8=Q',:pawn,   'd8'],
    ['Rd8+',  :rook,   'd8'],
    ['Qxf7#', :queen,  'f7'],
    ['d8=Q+', :pawn,   'd8'],
    ['f7!!',  :pawn,   'f7'],
    ['Qxa4?', :queen,  'a4']
  ]
    @valid_sans        = @sans.map{ |s| s[0] }    
    @valid_sans_movers = @sans.map{ |s| s[1] }
    @valid_sans_dest   = @sans.map{ |s| s[2] }
  end
  
  it 'should recognize most notations' do
    unrecognized = @valid_sans.select do |n|
      @parser.parse(n).nil?
    end
    unrecognized.should == []
  end

  it 'should recognize the piece that moved' do
    unmatched = []
    @valid_sans.each_with_index do |n, i|
      move = @parser.parse(n)
      unless move && move.piece == @valid_sans_movers[i]
        unmatched << n
      end
    end
    unmatched.should == []
  end

  it 'should recognize destinations' do
    unmatched = []
    @valid_sans.each_with_index do |n, i|
      move = @parser.parse(n)
      unless move && move.destination == @valid_sans_dest[i]
        unmatched << n
      end
    end
    unmatched.should == []
  end

 end
