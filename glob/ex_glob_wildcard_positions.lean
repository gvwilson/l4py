-- Write a function that finds all positions of Wild elements in a pattern
inductive Elem where | Lit (c : Char) | Any | Wild
  deriving Repr, BEq

def wildcardPositions (pat : List Elem) : List Nat :=
  []

#guard wildcardPositions [Elem.Lit 'a', Elem.Wild, Elem.Lit 'b', Elem.Wild] == [1, 3]
#guard wildcardPositions [Elem.Lit 'x'] == []
#guard wildcardPositions [Elem.Wild] == [0]