require File.dirname(__FILE__) + '/../test_helper'

class PlayerTest < ActiveSupport::TestCase
	
	fixtures :players
	
	#region Basic Tests
	def test_truth
		assert true
	end
	
	def test_can_create
		p = Player.new
		assert true
	end
	
	def test_stores_name
		name = "Deano"
		p = Player.new :name=>name
		
		assert_equal name, p.name
	end
	
    #endregion
	
	#region Test Environment Learning Tests
	
	#  before each test the fixtures data is loaded into the test database and 
	#  after each test it is destroyed. Mods can be done to the data within each
	#  method freely(provided the time it costs to do them is small enough) but
	#  each test only sees the fresh fixture data, not any polluted version from
	#  any other test
	def test_can_roundtrip_to_db_during_test
		@super_streak = "100/0"
		p = players(:dean)
		assert_not_equal p.win_loss, @super_streak
		
		p.win_loss = @super_streak
		p.save!
		
		p = Player.find_by_name "Dean"
		assert_equal p.win_loss, @super_streak
	end
	
	# because of the need to isolate tests from each other (to prevent the whole notion
	# of isolated unit testing from being polluted), instance variables set in previous
	# tests are not a good way of sharing information between tests. This suggests that
	# each test gets a fresh instance of the class
	# Note: the exception to this rule is for instance variables defined in the 'setup'
	# method - these run in the same instance as the test, just before each one 
	def test_instance_variable_INaccessible_in_later_tests
		assert_not_equal "100/0", @super_streak
	end
	
	# however class level variables are a possible way to communicate between tests since
	# the class is loaded once. That is not to say communication between tests should be 
	# done often - it's best used for more static data like constants.
	def test_class_variable_accessible_in_later_tests_1
		@@class_var_win_loss = "7/7"
	end
	
	# now prove this class variable will be accessible in later tests. Also,
	# update in db for later tests to prove the value doesn't persist across tests
	# and to flex our muscles with alternate ways of accessing the fixture data
	# - eg find_by_name, players(:dean)
	def test_class_variable_accessible_in_later_tests_2
		assert_equal "7/7", @@class_var_win_loss
		p = players(:dean)
		p.win_loss = @@class_var_win_loss
		p.save!
	end
	
	# if test fixtures are reloaded each time, we'd expect changes saved in previous
	def test_fixtures_freshly_reloaded_each_time
		p = Player.find_by_name "Dean"
		assert_not_equal @@class_var_win_loss, p.win_loss
		assert_equal "0/0", p.win_loss
	end
	
	
	#endregion
	
	#region Player Model Tests
	
	#endregion
	
	#region Player Database Integrity Tests
	def test_player_name_not_infinite
		#schema allows 20 chars max
		p = Player.new :name=>"3.141592653589793238462643383279502"
		
		#this is the version without model validation, which blows up and  
		# doesn't give us a return code to test for the assert statement below
		#assert_raise(ActiveRecord::StatementInvalid){
		#	p.save
		#}
		
		assert !p.valid?
		#message is off by %d vs. 20
		#assert_equal ActiveRecord::Errors.default_error_messages[:too_long],
		#	p.errors.on(:name)
		
	end
	def test_unique_player_name
		#already one named Dean loaded by fixture
		p = Player.new :name=>"Dean"
		assert !p.valid?
		assert !p.save
		
		#puts p.errors.on(:name)
		assert_equal ActiveRecord::Errors.default_error_messages[:taken],
		p.errors.on(:name)
	end
	#endregion
end
