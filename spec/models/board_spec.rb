require File.dirname(__FILE__) + '/../spec_helper'

describe Board do
  
  it 'should know a valid position by notation' do
    assert    Chess.valid_position?('a1')
    assert  ! Chess.valid_position?('n9')
    assert  ! Chess.valid_position?('a9')
    assert  ! Chess.valid_position?('1a')
  end
  
  it 'a pawn on its home square can move one or two' do
    match = matches(:unstarted_match)
    board = match.board

    pawn = board[:d2] #TODO we must do away with string access
    Pawn.should === pawn
    pawn.allowed_move?([0,1], 2).should == true
    pawn.allowed_move?([0,2], 2).should == true

    pawn.allowed_moves(board).should == [:d3, :d4]
  end

  it 'a bishop can not move if it is obstructed' do
    match = matches(:unstarted_match)
    board = match.board
    bishop = board[:c1]
    bishop.allowed_moves(board).should == []
  end  

  it 'scholars mate capture with queen should be checkmate' do
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
    printer.print(STDOUT, 0)

    # and it's over !!
    match.board.in_checkmate?(:black).should be_true
  end

  it 'scholars mate capture with bishop should not be checkmate' do
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
  it 'should know of the en_passant square once a pawn has made that move' do
    Board.any_instance.stubs(:in_check?).returns(false)
    match = matches(:unstarted_match)
    match.moves << Move.new(:from_coord => 'e2', :to_coord => 'e4')
    match.board.en_passant_square.should == 'e3'
  end

  it 'should pawn_can_capture_en_passant' do
    match = matches(:unstarted_match)
    
    match.moves << Move.new(:notation => 'e4') 
    match.moves << Move.new(:notation => 'a5')
    match.moves << Move.new(:notation => 'e5')
    match.moves << Move.new(:notation => 'd5')
    
    board = match.board
    assert_not_nil board['e5'] #just moved there
    
    assert_equal ['e6','d6'], board['e5'].allowed_moves(board)
    assert board.is_en_passant_capture?( 'e5', 'd6' )

    match.moves << Move.new(:from_coord => 'e5', :to_coord => 'd6')
    
    assert_equal 'd5', match.moves.last.captured_piece_coord
    assert_nil   match.board['d5'] 
  end	

  it 'should pawn_en_passant_not_possible_for_single_stepped_opponent_pawn' do
    m = matches(:unstarted_match)
    m.moves << Move.new(:notation => 'e4') << Move.new(:notation => 'd6')
    m.moves << Move.new(:notation => 'e5') << Move.new(:notation => 'd5')

    b = m.board
    assert_equal ['e6'], b['e5'].allowed_moves(b)
  end	

  #LEFTOFF restoring promotion
  it 'should promote automatically to queen' do
    Board.any_instance.stubs('in_check?').returns false

    m = matches(:promote_crazy)
    m.moves << promo = Move.new( :from_coord => 'b7', :to_coord => 'a8' )
    promo.should be_valid

    puts m.board.to_s
    m.moves.last.notation.should == 'bxa8=Q'
    m.board[:a8].function.should == :queen
  end

  it 'can promote to knight' do
    m = matches(:promote_crazy)
    m.moves << Move.new( :from_coord => 'b7', :to_coord => 'a8', :promotion_choice => 'N' )
    pending 'foo'
  end

  # consider yields a copy of the board on which the move has occurred
  it 'should considering_a_move_is_temporary' do
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

  it 'can output board in string format' do
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
