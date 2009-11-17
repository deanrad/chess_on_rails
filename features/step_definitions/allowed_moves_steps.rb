Given /^a board that looks like:$/ do |string_rep|
  @board = string_rep
end

When /^the piece at (\w\w) is queried for its allowed moves:$/ do |pos|
  puts pos
  puts @board
end

Then /^its list should include (.*)$/ do |expected_positions|
  1.should != 1
end
