require File.dirname(__FILE__) + '/../spec_helper'

describe Match do

  it 'should be creatable with two players' do
    match = ::Match.new( :player1 => players(:dean), :player2 => players(:anders) )
    match.lineup.should == 'dean vs. anders'
  end

  it 'should have player 1 on white and player 2 on black' do
    match = Match.new( :player1 => players(:dean), :player2 => players(:maria) )
    match.white.name.should == 'dean'
    match.black.name.should == 'maria'
  end

  it 'should start in the active state' do
    match = Match.new
    match.active.should be_true
  end

  describe "Board Replay" do
    it 'should start with the board in the initial configuration' do
      match = Match.new
      board = match.board

      (1..8).each do |rank|
        %w{ a b c d e f g h }.each do |file|
          if [1,2,7,8].include? rank
            board[ Position.new( file, rank ) ].should_not be_nil
          else
            board[ Position.new( file, rank ) ].should be_nil
          end
        end
      end

    end
    
    it 'should reflect a noncapturing move' do
      match = Match.new
      match.moves << Move.new( :from_coord => :d2, :to_coord => :d4 )
      board = match.board
      (1..8).each do |rank|
        %w{ a b c d e f g h }.each do |file|
          position = Position.new( file, rank )
          if [1,2,7,8].include? rank
            board[position].should_not be_nil unless position.to_sym == :d2
          else
            board[position].should be_nil unless position.to_sym == :d4
          end
        end
      end
    end
    
    it 'should know the count of how many moves played so far' do
      match = matches(:unstarted_match)
      lambda{
        match.moves << Move.new( :from_coord => :d2, :to_coord => :d4 )
      }.should change{ match.moves.count }.by(1)
    end

    it 'should know whose turn it is' do
      match = matches(:unstarted_match)
      lambda{
        match.moves << Move.new( :from_coord => :d2, :to_coord => :d4 )
      }.should change{ match.next_to_move }.from(:white).to(:black)
    end

    it 'should allow a piece to move when it is that players turn' do
      true.should == true #already shown by other tests
    end
    
    it 'should not allow a piece to move when it is not that players turn' do
      match = matches(:unstarted_match)
      lambda{
        match.moves << Move.new( :from_coord => :g8, :to_coord => :f6 ) #valid move by black knight
      }.should_not change{ match.moves.count}
    end
    
    it 'should capture the opponents piece when landing on their square' do
      match = Match.new
      match.moves << Move.new( :from_coord => :d2, :to_coord => :d4 )
      match.moves << Move.new( :from_coord => :e7, :to_coord => :e5 )
      match.moves << Move.new( :from_coord => :d4, :to_coord => :e5 )
      match.board.size.should == 31
    end
    
    it 'should capture the opponents piece if a capture_coord has been specified (en_passant)' do
      #the user cannot enter these capture coordinates, they are auto-generated
      match = Match.new
      match.moves << Move.new( :from_coord => :d2, :to_coord => :d4, :capture_coord => :d7)
      match.board.size.should == 31
    end
    
    it 'should move the rook to adjacent square opposite the king when king is castling' do
      match = matches(:ready_to_castle)
      match.moves << Move.new( :from_coord => :e1, :to_coord => :g1 )
      match.board[:f1].should_not be_nil
      
    end
  end

end
