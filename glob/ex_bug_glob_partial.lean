-- Lean reports "fail to show termination"; add the missing keyword
inductive Elem where | Lit (c : Char) | Any | Wild

def glob : List Elem → List Char → Bool
  | [],             []        => true
  | [],             _         => false
  | Elem.Wild :: [],  _      => true
  | Elem.Wild :: ps,  cs     =>
      (List.range (cs.length + 1)).any fun i =>
        glob ps (cs.drop i)
  | _, _ => false

#guard glob [Elem.Lit 'x'] ['x']