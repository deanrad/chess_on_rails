class ChessNotifier < ActionMailer::Base

  MINIMUM_TIME_BETWEEN_MOVE_NOTIFICATIONS = 1.0/24
  SENDER = "ChessOnRails Games<games@chessonrails.com>"

  # notifies @recipient that their opponent, @initiator, made move @move
  def player_moved(recipient, initiator, move)
    subject    "[ChessOnRails] #{initiator.name} made the move: #{move.notation}"
    recipients recipient.email
    from       SENDER
    sent_on    Time.now
    
    match = move.match
    board = match.reload.board
    
    board_string = board.to_s( match.side_of(recipient) == :black )
    body       :move => move, :recipient => recipient, :initiator => initiator, :board_string => board_string
  end

  # notifies @recipient has been invited to @match by @initiator
  def match_created(recipient, initiator, match)
    subject    "[ChessOnRails] #{initiator.name} has invited you to a match"
    recipients recipient.user.email
    from       SENDER
    sent_on    Time.now
    
    body       :match => match, :recipient => recipient, :initiator => initiator
  end
end
