# MatchObserver will send notifications to players invited to participate in a match
class MatchObserver < ActiveRecord::Observer
  # Send notifications
  def after_create(m)
    #logger.info "Match created #{m.lineup}"
  end
end
