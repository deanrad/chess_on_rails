module MatchHelper

  # checks for existance of .gif file in the current set's directory
  # if no .gif, uses .png extension
  def image_source_of( piece )
    "/images/sets/default/#{piece.role.to_s}_#{piece.side.to_s[0,1]}.gif"
    session[:set] ||= 'default'
    path = "/images/sets/#{session[:set]}/"
    extension = gif_file_exists?(piece, path) ? ".gif" : ".png"
    path + piece_file_name(piece) + extension
   end
  
  def piece_file_name(piece)
    "#{piece.role.to_s}_#{piece.side.to_s[0,1]}"
  end
  
  def gif_file_exists?(piece, path)
    File.exists?( Rails.public_path + path + piece_file_name(piece) + ".gif" )
  end

end
