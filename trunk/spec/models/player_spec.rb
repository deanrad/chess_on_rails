require File.dirname(__FILE__) + '/../spec_helper'

describe Player do

  it 'should create player' do
    assert_difference 'Player.count' do
      player = create_player
      player.new_record?.should_not be_true
    end
  end

  it 'should require login' do
    assert_no_difference 'Player.count' do
      u = create_player(:login => nil)
      u.errors.on(:login).should_not be_empty
    end
  end

  it 'should require password' do
    assert_no_difference 'Player.count' do
      u = create_player(:password => nil)
      u.errors.on(:password).should_not be_empty
    end
  end

  it 'should require password confirmation' do
    assert_no_difference 'Player.count' do
      u = create_player(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should_not be_empty
    end
  end

  it 'should require email' do
    assert_no_difference 'Player.count' do
      u = create_player(:email => nil)
      u.errors.on(:email).should_not be_empty
    end
  end

  #it 'should reset password' do
  #  players(:dean).update_attributes(:password => 'new password', :password_confirmation => 'new password')
  #  Player.authenticate('dean', 'new password').should_not be_nil
  #end

  #it 'should not rehash password' do
  #  players(:dean).update_attributes(:login => 'dean2')
  #  Player.authenticate(''
  #end

  it 'should authenticate player' do
    player = Player.authenticate('dean', '9')
    player.should_not be_nil
    player.name.should == 'dean'
  end
  

=begin
  it 'should set remember token' do
    players(:dean).remember_me
    players(:dean).remember_token.should_not be_nil
    players(:dean).remember_token_expires_at.should_not be_nil
  end

  it 'should unset remember token' do
    players(:dean).remember_me
    assert_not_nil players(:dean).remember_token
    players(:dean).forget_me
    assert_nil players(:dean).remember_token
  end

  it 'should remember me for one week' do
    before = 1.week.from_now.utc
    players(:dean).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil players(:dean).remember_token
    assert_not_nil players(:dean).remember_token_expires_at
    players(:dean).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'should remember me until one week' do
    time = 1.week.from_now.utc
    players(:dean).remember_me_until time
    assert_not_nil players(:dean).remember_token
    assert_not_nil players(:dean).remember_token_expires_at
    time.should == players(:dean).remember_token_expires_at
  end

  it 'should remember me default two weeks' do
    before = 2.weeks.from_now.utc
    players(:dean).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil players(:dean).remember_token
    assert_not_nil players(:dean).remember_token_expires_at
    players(:dean).remember_token_expires_at.between?(before, after).should be_true
  end
=end

protected
  def create_player(options = {})
    record = Player.new({ :login => 'deano', :email => 'deano@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    record.save
    record
  end
  
end
