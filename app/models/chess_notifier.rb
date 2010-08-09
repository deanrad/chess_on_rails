class ChessNotifier < ActionMailer::Base

  MINIMUM_TIME_BETWEEN_MOVE_NOTIFICATIONS = 1.0/24
  SENDER = "ChessOnRails Games<games@chessonrails.com>"

  # notifies @recipient that their opponent, @initiator, made move @move
  def opponent_moved(recipient, initiator, move)
    subject    "#{initiator.name} made the move: #{move.notation}"
    recipients recipient.email
    from       SENDER
    sent_on    Time.now
    
    body       :move => move
  end

  # notifies @recipient has been invited to @match by @initiator
  def match_created(recipient, initiator, match)
    subject    "#{initiator.name} has invited you to a match"
    recipients recipient.user.email
    from       SENDER
    sent_on    Time.now
    
    body       :match => match, :recipient => recipient
  end
end
