Given /a new chess board/ do
  @board = Chess.new_board
end

Given /a board like the following/ do |board|
  pending
end

When /^I move from ([a-h]\d) to ([a-h]\d)$/ do |from_coord, to_coord|
  @board.play_move! Move.new(:from_coord => from_coord, :to_coord => to_coord)
end

Then /^the board should look like$/ do |board|
#  @board.to_s.gsub(/\n\s+(?=\n)/, "\n").should == board
#  @board.to_s.gsub(/\n\ +(?=\n)/, "\n").should == board
  @board.to_s.sub(/\n+$/,"").should == board
end