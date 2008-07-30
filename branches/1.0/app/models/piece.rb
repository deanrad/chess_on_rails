# A Piece is a transient object, not stored in the database, but inferred, queried, used
# and disposed as needed for the purpose of validating +moves+ and implementing gameplay
#
# All piece types are instance of the same class +Piece+, and include types described at:
# http://en.wikipedia.org/wiki/Chess
#
# There are varying levels of specificity when describing a +Piece+
# board_id::  unique to any piece on board - +white_kings_rook+, +black_a_pawn+, +black_queen+
# side_id::   unique to any piece on one side - +kings_rook+, +queen+
# role::      which set of rules apply to this piece - +rook+, +bishop+, +pawn+
# color::     +white+, +black+
# flank::     +kings+, +queens+
# which::     +a+, +kings+  (in other words, the +flank+ for minor pieces, the file for pawns)
class Piece 
end
