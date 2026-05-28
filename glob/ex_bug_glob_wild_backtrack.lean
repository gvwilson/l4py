-- Wild backtracking range is off by one; should try consuming ALL chars
inductive Elem where | Lit (c : Char) | Any | Wild

partial def glob : List Elem → List Char → Bool
  | Elem.Wild :: [],  _      => true
  | Elem.Wild :: ps,  cs     =>
      (List.range cs.length).any fun i =>
        glob ps (cs.drop i)
  | [], [] => true
  | _, _ => false

-- This should match (Wild consumes all of "abc")
#guard glob [Elem.Wild, Elem.Lit 'c'] ['a', 'b', 'c']