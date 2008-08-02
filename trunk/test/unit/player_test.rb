require File.dirname(__FILE__) + '/../test_helper'

class PlayerTest < Test::Unit::TestCase

=begin
  def test_should_create_player
    assert_difference 'Player.count' do
      player = create_player
      assert !player.new_record?, "#{player.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference 'Player.count' do
      u = create_player(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference 'Player.count' do
      u = create_player(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'Player.count' do
      u = create_player(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference 'Player.count' do
      u = create_player(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    players(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal players(:quentin), Player.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    players(:quentin).update_attributes(:login => 'quentin2')
    assert_equal players(:quentin), Player.authenticate('quentin2', 'test')
  end

  def test_should_authenticate_player
    assert_equal players(:quentin), Player.authenticate('quentin', 'test')
  end

  def test_should_set_remember_token
    players(:quentin).remember_me
    assert_not_nil players(:quentin).remember_token
    assert_not_nil players(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    players(:quentin).remember_me
    assert_not_nil players(:quentin).remember_token
    players(:quentin).forget_me
    assert_nil players(:quentin).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    players(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil players(:quentin).remember_token
    assert_not_nil players(:quentin).remember_token_expires_at
    assert players(:quentin).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    players(:quentin).remember_me_until time
    assert_not_nil players(:quentin).remember_token
    assert_not_nil players(:quentin).remember_token_expires_at
    assert_equal players(:quentin).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    players(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil players(:quentin).remember_token
    assert_not_nil players(:quentin).remember_token_expires_at
    assert players(:quentin).remember_token_expires_at.between?(before, after)
  end

protected
  def create_player(options = {})
    record = Player.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    record.save
    record
  end
=end
  
end
