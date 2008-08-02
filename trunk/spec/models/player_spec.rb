require File.dirname(__FILE__) + '/../spec_helper'

describe Player do

=begin
  it 'should create player' do
    assert_difference 'Player.count' do
      player = create_player
      player.new_record?.should_not be_true
    end
  end

  it 'should require login' do
    assert_no_difference 'Player.count' do
      u = create_player(:login => nil)
      u.errors.on(:login).should be_true
    end
  end

  it 'should require password' do
    assert_no_difference 'Player.count' do
      u = create_player(:password => nil)
      u.errors.on(:password).should be_true
    end
  end

  it 'should require password confirmation' do
    assert_no_difference 'Player.count' do
      u = create_player(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should be_true
    end
  end

  it 'should require email' do
    assert_no_difference 'Player.count' do
      u = create_player(:email => nil)
      u.errors.on(:email).should be_true
    end
  end

  it 'should reset password' do
    players(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    'new password').should == players(:quentin), Player.authenticate('quentin'
  end

  it 'should not rehash password' do
    players(:quentin).update_attributes(:login => 'quentin2')
    'test').should == players(:quentin), Player.authenticate('quentin2'
  end

  it 'should authenticate player' do
    'test').should == players(:quentin), Player.authenticate('quentin'
  end

  it 'should set remember token' do
    players(:quentin).remember_me
    assert_not_nil players(:quentin).remember_token
    assert_not_nil players(:quentin).remember_token_expires_at
  end

  it 'should unset remember token' do
    players(:quentin).remember_me
    assert_not_nil players(:quentin).remember_token
    players(:quentin).forget_me
    assert_nil players(:quentin).remember_token
  end

  it 'should remember me for one week' do
    before = 1.week.from_now.utc
    players(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil players(:quentin).remember_token
    assert_not_nil players(:quentin).remember_token_expires_at
    players(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'should remember me until one week' do
    time = 1.week.from_now.utc
    players(:quentin).remember_me_until time
    assert_not_nil players(:quentin).remember_token
    assert_not_nil players(:quentin).remember_token_expires_at
    time.should == players(:quentin).remember_token_expires_at
  end

  it 'should remember me default two weeks' do
    before = 2.weeks.from_now.utc
    players(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil players(:quentin).remember_token
    assert_not_nil players(:quentin).remember_token_expires_at
    players(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

protected
  def create_player(options = {})
    record = Player.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    record.save
    record
  end
=end
  
end
