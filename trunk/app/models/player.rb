require 'digest/sha1'

# A Player is a participant in any Chess match, or simply a known account of someone.
# It was used as the Restful Authentication user model so @current_player is used instead
# of @current_user.
# Other authentication types like facebook, or OpenID, when implemented will simply map
# their identities onto instances of +Player+ in this application
class Player < ActiveRecord::Base

  has_many  :matches, :class_name=>"Match",
    :finder_sql=>'SELECT matches.* FROM matches WHERE ( player1_id = #{id} OR player2_id = #{id} )'

  def name
    login
  end
  
  # Default Restful Authentication properties follow 
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

=begin  # Not utilizing this boilerplate Restful Auth functionality at the moment
  #def remember_token?
  #  remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  #end

  # These create and unset the fields required for remembering users between browser closes
  #def remember_me
  #  remember_me_for 2.weeks
  #end

  #def remember_me_for(time)
  #  remember_me_until time.from_now.utc
  #end

  #def remember_me_until(time)
  #  self.remember_token_expires_at = time
  #  self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
  #  save(false)
  #end

  #def forget_me
  #  self.remember_token_expires_at = nil
  #  self.remember_token            = nil
  #  save(false)
  #end

  # Returns true if the user has just been activated.
  #def recently_activated?
  #  @activated
  #end
=end

  #default_salt used by fixtures
  def self.fixtures_salt
    '7e3041ebc2fc05a40c60028e2c4901a81035d3cd'
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    
end
