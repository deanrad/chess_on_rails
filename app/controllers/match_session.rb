# MatchSession:
# Like a session, but available through 'match_session' instead of 'session'. The 
# methods on this object can be thought of as keys in a regular CGI::Session object,
# However writing your app to an instance of this object, rather than a CGI::Session
# will ensure flexibility when you consider different strategies for storing client-
# specific state.
# Calls like
#    session[:matches][ params[:match_id] ][:set] ||= 'default'
# Become
#    match_session.set
# 
# and now the logic for initializing/defaulting session variables is consolidated 
# into one place instead of littered throughout controllers.
class MatchSession

  # The match session may store/retrieve its values from the session
  def initialize(cgi_session, match_id)
    unless match_id 
      # raise ArgumentError 
      $stderr.puts "No match_id #{__FILE__} #{__LINE__}"
    end

    with (self.session = cgi_session) do |sess|
      sess[:matches] ||= {}
      sess[:matches][ match_id ] ||= Match[match_id]  
    end
    self
  end

  module ExtensionMethods
    # BEGIN Session-extension methods
    def set
      self[:set] ||= 'default'
    end
    def matches
      self[:matches] ||= Match.matches
    end
  end   # ExtensionMethods

  
  ########################## ACHTUNG CUIDADO ###########################
  private

  # the cached reference to the CGI::Session
  attr_accessor :session
end
