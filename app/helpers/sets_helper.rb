module SetsHelper
  
  def available_sets
    Dir.glob("#{Rails.public_path}/images/sets/**").
        select{|f| File.directory?( f) }.
        map{|d| d.split("/").last}
  end

end