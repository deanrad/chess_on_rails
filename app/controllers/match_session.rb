# MatchSession:
# Like a session, but available through 'match_session' instead of 'session'. The 
# methods on this object can be thought of as keys in a regular CGI::Session object,
# However writing your app to an instance of this object, rather than a CGI::Session
# will ensure flexibility when you consider different strategies for storing client-
# specific state.
# Calls like
#    session[:set] ||= 'default'
# Become
#    match_session.set
# 
# and now the logic for initializing/defaulting session variables is consolidated 
# into one place instead of littered throughout controllers.
class MatchSession
  module ControllerInstanceMethods
    def can_fly_to_moon; true; end
    def match_session;  MatchSession.new(session) ; end
  end

  # The match session may store/retrieve its values from the session
  def initialize(cgi_session)
    self.session = cgi_session
  end

  # BEGIN Session-extension methods
  def set
    session[:set] ||= 'default'
  end
  # END   Session-extension methods

  # Below here are the internals we shield callers from.
  private
  attr_accessor :session
end
