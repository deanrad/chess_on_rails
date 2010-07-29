module MatchHelper

  def match
    @match ||= request.match
  end

  # allows for multiple sets 
  def image_source_of( piece )
    "/images/sets/default/#{piece.img_name}.png"
  end

end
