require File.dirname(__FILE__) + '/../spec_helper'

describe Board do
  it 'should know a valid position by notation' do
    Board.valid_position?(:a1).should == true
    Board.valid_position?(:n9).should == false
    Board.valid_position?(:a9).should == false
    Board.valid_position?('1a').should == false
    Board.valid_position?('a1').should == true
  end
  
  it 'should allow a pawn on its home square to move one or two' do
    match = matches(:unstarted_match)
    board = match.board

    pawn = board[:d2] 
    pawn.allowed_moves(board).should == [:d4, :d3]
  end

  it 'a bishop can not move if it is obstructed' do
    board = Board.new( :c1 => bishop=Bishop.new(:white) )
    bishop.allowed_moves(board).length.should > 0

    # obstruct him - now he can go nowhere 
    board[:b2] = board[:d2] = Pawn.new(:white)
    bishop.allowed_moves(board).length.should == 0    
  end  

  it 'scholars mate capture with queen should be checkmate' do
    Board.any_instance.stubs(:'in_check?').returns(true) # '

    match = matches(:scholars_mate)
    match.board['f3'].function.should == :queen

    #make the killer move    
    match.moves << killer = Move.new( :notation => 'Qf7' )

    #king is in check
    RubyProf.start
    match.board.in_check?(:black).should be_true

    result = RubyProf.stop

    # Print a flat profile to text
    printer = RubyProf::FlatPrinter.new(result)
    #printer.print(STDOUT, 0)

    # and it's over !!
    match.board.in_checkmate?(:black).should be_true
  end

  it 'scholars mate capture with bishop should not be checkmate' do
    Board.any_instance.stubs(:'in_check?').returns(false) # '
    match = matches(:scholars_mate)
    match.moves << Move.new( :notation => 'Bxf7' )
    match.board.in_check?(:black).should be_false

    match.board['e8'].allowed_moves(match.board).should include(:e7)
    
    match.board.should_not be_in_checkmate( :black )
  end

  it 'should have no available en_passant sqaure to begin with' do
    match = matches(:unstarted_match)
    match.board.en_passant_square.should be_nil
  end

  it 'should record the en_passant square for a duration of one move' do
    match = matches(:unstarted_match)
    match.moves << Move.new(:from_coord => 'e2', :to_coord => 'e4')
    match.board.en_passant_square.should == :e3

    match.moves << Move.new(:from_coord => 'e7', :to_coord => 'e5')
    match.board.en_passant_square.should == :e6

    match.moves << move = Move.new(:notation => 'Nc3')
    match.board.en_passant_square.should == nil
  end

  it 'should allow pawn to capture en passant' do
    match = matches(:unstarted_match)
    
    match.moves << Move.new(:notation => 'e4') 
    match.moves << Move.new(:notation => 'a5')
    match.moves << Move.new(:notation => 'e5')
    match.moves << Move.new(:notation => 'd5')
    
    board = match.board

    board.en_passant_square.to_sym.should == :d6
    
    board[:e5].allowed_moves(board).should include(:d6, :e6)
    
    match.moves << Move.new(:from_coord => 'e5', :to_coord => 'd6')
    assert_equal 'd5', match.moves.last.captured_piece_coord
    assert_nil   match.board['d5'] 
  end	

  it 'should prohibit en_passant when not available' do
    m = matches(:unstarted_match)
    m << 'e4'; m << 'd6'
    m << 'e5'; m << 'd5'

    b = m.board
    b[:e5].allowed_moves(b).should_not include(:e5)
  end	

  it 'should promote automatically to queen' do
    pending 'promotion'
    m = matches(:promote_crazy)
    
    m.moves << promo = Move.new( :from_coord => 'b7', :to_coord => 'b8' )
    promo.should be_valid 

    m.moves.last.notation.should == 'b8=Q'
    m.board[:b8].function.should == :queen
  end

  it 'should be able to promote to knight' do
    pending 'promotion'
    m = matches(:promote_crazy)
    m.moves << Move.new( :from_coord => 'b7', :to_coord => 'a8', :promotion_choice => 'N' )
    m.moves.last.notation.should == 'bxa8=N'
    m.board[:a8].function.should == :queen
  end

  # consider yields a copy of the board on which the move has occurred
  it 'should allow consideration of a move without altering the board' do
    match = matches(:unstarted_match)
    board = match.board
    board['a2'].side.should == :white
    board['e7'].side.should == :black
    
    board.consider_move( Move.new( :from_coord => 'a2', :to_coord => 'a4'  ) ) do |new_board|
      new_board['a2'].should     be_nil
      new_board['a4'].should_not be_nil
    end

    board['a2'].should_not be_nil
    board['a4'].should     be_nil
  end 

  it 'should have a different hash code per board configuration' do
    b = Board.new
    lambda{
      b.play_move!( Move.new(:from_coord=>'d2', :to_coord=>'d4') )
    }.should change{ b.hash }
  end

  it 'should have a nice string format' do
    match = matches(:unstarted_match)
    board = match.board
    board.to_s.should == <<-DaBoard
r n b q k b n r
p p p p p p p p
               
               
               
               
P P P P P P P P
R N B Q K B N R

DaBoard
  end
end
