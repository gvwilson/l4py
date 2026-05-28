-- This says [Elem.Any] matches empty input, but it shouldn't
inductive Elem where | Any | Lit (c : Char) | Wild
  deriving Repr, BEq

def matchAny (es : List Elem) (cs : List Char) : Bool :=
  match es, cs with
  | Elem.Any :: _, [] => true
  | Elem.Any :: _, _ :: cs' => true
  | _, _ => false

#guard matchAny [Elem.Any] ['x']
#guard !matchAny [Elem.Any] []