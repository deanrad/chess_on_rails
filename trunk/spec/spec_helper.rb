# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'


#lets us play a move against an arbitrary board without concern for having to have a set of moves that play
# up to that board
def create_move_against_match_with_board( match, board, move_info )
  #inject the prefab board into the match via its instance variable
  match.instance_variable_set( :@board, board )
  
  #create move for this match 
  move = match.moves.build( move_info )
  
  #and since unlike DataMapper, to keep this move from creating a new match instance (for the same)
  # database ID, we inject the match instance into the move so its validations will check the board
  # we set up earlier
  move.match = match #this is necessary to keep it from looking up and replaying its board
  
  #let the caller have the move to append to match.moves when it likes
  move
end
  
#normal configuration follows
Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  
  
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  include AuthenticatedTestHelper

  config.global_fixtures = :matches, :players, :moves
  
end

#patch to prevent an RSpec error with certain versions
class Object
  def metaclass
    (class << self; self; end)
  end
end

