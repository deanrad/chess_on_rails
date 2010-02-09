class EventsController < ApplicationController

  # Returns an array of JSON hashes of events which have happened on this match
  def index
    @event_hashes = (match.moves + match.chats).map(&:to_client_hash)
    @event_hashes.each_with_index do |e, idx|
      e[:event_id] = idx+1
    end
    render :json => @event_hashes.map(&:to_json)
  end

end
