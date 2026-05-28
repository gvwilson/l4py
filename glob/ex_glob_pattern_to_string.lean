-- Write a function that converts a list of Elem back to a pattern string
inductive Elem where | Lit (c : Char) | Any | Wild
  deriving Repr, BEq

def patternToString (pat : List Elem) : String :=
  ""

#guard patternToString [Elem.Lit 'h', Elem.Any, Elem.Lit 't', Elem.Wild] == "h?t*"
#guard patternToString [Elem.Wild, Elem.Lit '.', Elem.Lit 't', Elem.Lit 'x', Elem.Lit 't'] == "*.txt"
#guard patternToString [] == ""