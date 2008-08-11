require File.dirname(__FILE__) + '/../spec_helper'

describe Move, 'A move' do

  it "should be invalid without a from and to coordinate" do
    m = Move.new( :from_coord => :d4 )
    m.valid?.should == false
  end
  
  it 'should be able to use symbols to refer to its coordinates' do
    m = Move.new(:from_coord => :a2, :to_coord => :a4)
    m.from_coord.should == :a2
    m.to_coord.should == :a4
    
    m.capture_coord = :a4
    m.capture_coord.should == :a4
  end
  
  it 'should have its coordinates returned from database as symbols' do
    matches(:dean_vs_maria).moves.first.to_coord.should == :d4
  end

  it 'should be invalid with any invalid coordinates' do 
    move = Move.new(:from_coord => :a2, :to_coord => 'broken')
    move.should_not be_valid
  end
  
  it 'should know which side is moving (during validation)' do
    match = matches(:unstarted_match)
    move = match.moves.build(:from_coord => :g1, :to_coord => :f3)
    match.moves << move
    move.side_moving.should == :white
  end
  
  it 'should populate the capture coordinate field of a move when capturing enpassant' do

    #note - here we are forcefeeding a board in to the match 
    match = matches(:unstarted_match)
    board = Board[ :d5 => Pawn.new(:white, :d), :c5 => Pawn.new(:black, :c) ] 

    move = create_move_against_match_with_board( match, board, :from_coord => :d5, :to_coord => :c6 )

    match.moves << move
    move.capture_coord.should == :c5
  end

  it 'should populate the castled field of a move when a king castles' do
    #note - here we are forcefeeding a board in to the match 
    match = matches(:unstarted_match)
    board = Board[ :e1 => King.new(:white), :h1 => Rook.new(:white, :kings) ] 
    
    move = create_move_against_match_with_board( match, board, :from_coord => :e1, :to_coord => :g1 )

    match.moves << move
    move.castled.should be_true
  end
  
  it 'should be invalid if it leaves your own king in check' do
    match = matches(:scholars_mate)
    match.moves << Move.new( :from_coord => :c4, :to_coord => :f7 ) #white bishop checks black king
    lambda{
      move = match.moves.build( :from_coord => :a7, :to_coord => :a5 ) #black does not move out of check
      match.moves << move
    }.should_not change{ match.moves.count }

  end
  
  it 'should mark match as finished when checkmating move completed' do
    match = matches(:scholars_mate)
    match.moves << Move.new( :from_coord => :h5, :to_coord => :f7 )
    
    # this reload is necessary since the instance that move after_save has access to is not the same 
    # instance that we have here (a problem which DataMapper in Merb addresses but we must live with in AR)
    match.reload 
    match.active.should be_false
    match.winner.id.should == match.player1.id
  end

  it 'should populate the promtion field of a move when a default queen promotion' do
    match = matches(:unstarted_match)
    board = Board[ :d7 => Pawn.new(:white, :d) ] 
    
    move = create_move_against_match_with_board( match, board, :from_coord => :d7, :to_coord => :d8 )

    match.moves << move
    move.promotion_piece.should == 'Q'
  end
  
  it 'should populate the move number for a move'
  
  it 'should populate the notation for a move'
  
end
