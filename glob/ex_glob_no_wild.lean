-- Write a function that checks if a pattern has no wildcards (no * or ?)
inductive Elem where | Lit (c : Char) | Any | Wild
  deriving Repr, BEq

def hasNoWildcards (pat : List Elem) : Bool :=
  true

#guard hasNoWildcards [Elem.Lit 'a', Elem.Lit 'b']
#guard !hasNoWildcards [Elem.Lit 'a', Elem.Wild]
#guard !hasNoWildcards [Elem.Any]
#guard hasNoWildcards []