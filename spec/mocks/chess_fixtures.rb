#One way we could provide a hook into fixtures - define this module and 
# mix into Spec::Example::ExampleGroup
module ChessFixtures
  
  @@fixtures = {}
  
  def matches( which )
    #todo - get a fresh object from the object repository 
    @@fixtures[:unstarted_match] = begin
      m = Match.new
    end
    @@fixtures[:ready_to_castle] = begin
      m = Match.new( :board => Board[:a1 => Rook.new(:white, :queens), :e1 => King.new(:white), :h1 => Rook.new(:white, :kings)])
    end

    #else check our fixtures file
    moves = moves_for_match(which)
    if moves.length > 0
      match = Match.new( :name => which.to_s )
      moves.each{ |move| match.moves << move }
      @@fixtures[which] = match
    end

    unless @@fixtures.keys.include? which
      raise Exception, "Dont have fixture #{which} in repository" 
    end
    @@fixtures[which]
  end

  #if match_spec is dependent on players fixtures (it is), we have an organizational issue
  def players( which )
    p = Player.new( :login => which.to_s )
    p
  end
  
  #Read the moves.csv for matching lines  #TODO really ugly and hacky
  require 'csv'
  def moves_for_match( match_name )
    moves_path =  File.expand_path( File.join( File.dirname( __FILE__), "/../fixtures/moves.csv" ) )
    csv = CSV.open( moves_path, "r" )    
    moves = []
    csv.shift #skip first headers - go positional !
    csv.each do |row|
      #scholars_mate,1, e2, e4, e4
      if row[0]==match_name.to_s
        moves << Move.new( :from_coord => row[2], :to_coord => row[3], :notation => row[4] ) 
      end
    end
    moves
  end
end
