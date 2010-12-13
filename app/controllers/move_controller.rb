class MoveController < ApplicationController

  before_filter :authorize

  #accessible via get or post but should be idempotent on 2x get
  def create

    raise ArgumentError, "It is your not your turn to move yet" unless request.your_turn?

    match.moves << @move = Move.new( params[:move] )
    flash[:error] = @move.errors.full_messages unless @move.id

    # not working ! see checks in prod matches 75/78
    # HA ! memoization screwed it up !
    # [:black, :white].each do |side| 
    #  match.checkmate_by(side.opposite) if match.reload.board.in_checkmate?(side)
    # end
    
    # TODO abstract out this chat/email communication system. Mock during dev/tests
    chat_successful = false
    if Rails.env.production? && request.opponent.email =~ /gmail.com/
      h = Net::HTTP.new('xmppfu.appspot.com')
      case h.get("/?recipient=#{request.opponent.email}&notation=#{@move.notation}&match_id=#{@move.match.id}")
      when Net::HTTPSuccess
        chat_successful = true
      end
    end
    ChessNotifier.deliver_player_moved(request.opponent, request.player, @move) unless chat_successful
    
    
    return render :json => @move.to_json if request.xhr?

    redirect_to match_path(match) + (request.mobile? ? '.wml' : '')
    
  end
  
end
