module MatchHelper

  def match
    @match ||= request.match
  end

  # allows for multiple sets 
  def image_source_of( piece )
    "/images/sets/default/#{piece.img_name}.png"
  end

  #       <a href="<%= piece_link(board, piece, position) %>" onclick="<%= piece_action(board, piece, position) %>"
  #            ><img src="<%= piece_img_src(board, piece, position) %>" height="20" width="20"/></a>
  def piece_markup board, piece, position
    unlinked = <<-EOF
      <img src="#{piece_img_src(board, piece, position)}" height="20" width="20" border="0" class="piece" /></a>
    EOF
    # return unlinked unless piece && piece.allowed_moves(board).length != 0
    linked = <<-EOF
      <a href="#{piece_link(board, piece, position)}" onclick="#{piece_action(board, piece, position)}">#{unlinked}</a>
    EOF
  end

  # the URL a piece is hyperlinked to (a URL to select the piece for this game)
  def piece_link board, piece, position
    "/match/#{match.id}.wml?from_coord=#{position}"
  end

  # the javascript ation a piece is hyperlinked to (will supersede and may cancel the action)
  def piece_action board, piece, position
    js=<<-EOF
      select_position( '#{position}' ); return false;
    EOF
  end

  def piece_img_src board, piece, position
    return '/images/spacer.gif' unless piece
    "/images/sets/default/#{piece.img_name}.png"
  end
end
