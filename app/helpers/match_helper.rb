module MatchHelper

  # checks for existance of .gif file in the current set's directory
  # if no .gif, uses .png extension
  def image_source_of( piece )
    "/images/sets/default/#{piece.img_name}.gif"
    session[:set] ||= 'default'
    path = "/images/sets/#{session[:set]}/"
    extension = gif_file_exists?(piece, path) ? ".gif" : ".png"
    path + piece.img_name + extension
   end
  
  def gif_file_exists?(piece, path)
    File.exists?( Rails.public_path + path + piece.img_name + ".gif" )
  end

end
