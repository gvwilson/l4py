-- Write a function that filters a list of strings by a glob pattern
inductive Elem where | Lit (c : Char) | Any | Wild
  deriving Repr, BEq

partial def glob : List Elem → List Char → Bool
  | [],             []        => true
  | [],             _         => false
  | Elem.Wild :: [],  _      => true
  | Elem.Wild :: ps,  cs     =>
      (List.range (cs.length + 1)).any fun i =>
        glob ps (cs.drop i)
  | Elem.Lit c :: ps, c' :: cs => c == c' && glob ps cs
  | Elem.Lit _ :: _,  []      => false
  | Elem.Any   :: ps, _ :: cs => glob ps cs
  | Elem.Any   :: _,  []      => false

def matchGlob (pat : List Elem) (s : String) : Bool :=
  glob pat s.toList

def parsePat (s : String) : List Elem :=
  s.toList.filterMap fun c =>
    if c == '?' then some Elem.Any
    else if c == '*' then some Elem.Wild
    else some (Elem.Lit c)

def filterGlob (patStr : String) (files : List String) : List String :=
  []

#guard filterGlob "*.lean" ["a.lean", "b.txt", "c.lean"] == ["a.lean", "c.lean"]