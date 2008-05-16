require File.dirname(__FILE__) + '/../test_helper'

class PlayerTest < ActiveSupport::TestCase
	
	fixtures :players
	
	#region Basic Tests
	def test_truth
		assert true
	end
	
	def test_can_be_created
		p = Player.new
		assert true
	end
	
	def test_stores_name
		name = "Deano"
		p = Player.new :name=>name
		
		assert_equal name, p.name
	end
	
    #endregion
	
	
	def test_reject_registering_duplicate_player_names
		#already one named Dean loaded by fixture
		p = Player.new :name=>"Dean"
		assert !p.valid?
		assert !p.save
		
		#puts p.errors.on(:name)
		assert_equal ActiveRecord::Errors.default_error_messages[:taken],
		p.errors.on(:name)
	end
end
