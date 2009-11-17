Scenario Outline: Allowed move deduction
  Given a board that looks like:
    """
    r n b q k b n r
    p p p p p p p p
               
               
               
               
    P P P P P P P P
    R N B Q K B N R
    """
  When the piece at <Pos> is queried for its allowed moves:
  Then its list should include <Expected>
  Examples:
    |  d2     | d3, d4                                         |
