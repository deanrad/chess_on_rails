#Lets make sure our symbol tables are loaded up early in the programs life
Position::POSITIONS.each{ |p| p.intern }
