-- The match arms are in the wrong order: empty match should be tried first
inductive Elem where | Lit (c : Char) | Any | Wild

def glob : List Elem → List Char → Bool
  | Elem.Wild :: [],  _      => true
  | [],             []        => true
  | [],             _         => false
  | _, _ => false

#guard glob [] []
#guard !glob [] ['x']