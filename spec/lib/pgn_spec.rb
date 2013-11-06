require File.dirname(__FILE__) + '/../spec_helper.rb'


describe Pgn do
  WITH_TAGS = <<EOF
[Event "F/S Return Match"]
[Site "Belgrade, Serbia JUG"]
[Date "1992.11.04"]
[Round "29"]
[White "Fischer, Robert J."]
[Black "Spassky, Boris V."]
[Result "1/2-1/2"]

1. e4 e5 2. Nf3 Nc6 3. Bb5 a6
4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O 9. h3 Nb8  10. d4 Nbd7

EOF

  EVEN_MOVES = "1. e4 e5 2. Nc3 Nf6"
  ODD_MOVES =  "1. e4\te5 \n2. Nc3"
 
  before(:all) do 
  end

  it 'should detect tags in beginning' do
    pgn = Pgn.new(WITH_TAGS)
    pgn.tags.should_not be_empty
    pgn[:round].should == "29"
  end

  it 'should detect an even number of moves' do
    pgn = Pgn.new(PgnExamples::EVEN_MOVES)
    pgn.notations.length.should == 4
    pgn.notations[0].should == 'e4'
    pgn.notations[1].should == 'e5'
    pgn.notations[2].should == 'Nc3'
    pgn.notations[3].should == 'Nf6'
  end

  it 'should detect an odd number of moves' do
    pgn = Pgn.new(PgnExamples::ODD_MOVES)
    pgn.notations.length.should == 3
    pgn.notations[0].should == 'e4'
    pgn.notations[1].should == 'e5'
    pgn.notations[2].should == 'Nc3'
  end

  it 'should scan in spite of comments' do
    pgn = Pgn.new(PgnExamples::WITH_COMMENTS)
    pgn.notations.length.should == 20
  end

  it 'should know that a FEN is not a Pgn' do
    Pgn.is_pgn?( 'RNBQKBNR/PPPP1PPP/4P3/8/8/8/pppppppp/rnbqkbnr b' ).should be_false
  end

  it 'should know an invalid Pgn when it sees one' do
    pgn = Pgn.new( 'ooga booga' )
    pgn.should_not be_valid
  end

  # an integration test unless match stuff is stubbed..
  it 'should be able to playback Pgn against a match' do
    Board.any_instance.stubs('in_check?').returns false

    m = matches(:unstarted_match)
    pgn = Pgn.new('1. e4 e5')
    pgn.playback_against(m)

    pgn.playback_errors.should be_blank
    m.moves.length.should == 2
  end

  it 'should save playback errors' do
    Board.any_instance.stubs('in_check?').returns false

    m = matches(:unstarted_match)
    pgn = Pgn.new('1. e4 e5 2. Nd7')
    pgn.playback_against(m)
    
    m.reload.moves.length.should == 2

    m.moves.first.notation.should == 'e4'

    pgn.playback_errors.should_not be_blank
  end
end
