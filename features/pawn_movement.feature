Feature: Pawn movement
  In order to comply with the rules of chess
  As a pawn
  I want to move correctly

  Scenario: The opening move
    Given a new chess board
    When I move from d2 to d4
    Then the board should look like
"""
r n b q k b n r
p p p p p p p p
               
               
      P        
               
P P P   P P P P
R N B Q K B N R
"""
     