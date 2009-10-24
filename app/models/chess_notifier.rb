class ChessNotifier < ActionMailer::Base

  SENDER = ""

  # notifies that the opponent made a move
  def opponent_moved(plyr, opp, mv)
    subject    "#{opp.name} made a move: #{mv.notation}"
    recipients plyr.user.email
    from       SENDER
    sent_on    Time.now
    
    # The hash of items to become instance variables in the view
    body       :move => mv, :match => mv.match
  end

  # notifies that the player has been invited to a match by opponent
  def match_created(plyr, opp, match)
    subject    "#{opp.name} has invited you to a match"
    recipients plyr.user.email
    from       SENDER
    sent_on    Time.now
    
    # The hash of items to become instance variables in the view
    body       :match => match
  end
end