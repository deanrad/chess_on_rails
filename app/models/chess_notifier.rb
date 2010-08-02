class ChessNotifier < ActionMailer::Base

  SENDER = "ChessOnRails Games<games@chessonrails.com>"

  # notifies player that their opponent in match N made a move
  def opponent_moved(recipient, initiator, data_obj)
    subject    "#{initiator.name} made the move: #{data_obj.notation}"
    recipients recipient.email
    from       SENDER
    sent_on    Time.now
    
    # The hash of items to become instance variables in the view
    body       :move => mv, :match => mv.match, :board => mv.match.board.to_s
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
