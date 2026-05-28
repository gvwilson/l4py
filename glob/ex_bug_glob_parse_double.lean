-- One case is unreachable; '?' should map to Any, not Wild
inductive Elem where | Lit (c : Char) | Any | Wild

def parsePat (s : String) : List Elem :=
  s.toList.filterMap fun c =>
    if c == '*' then some Elem.Wild
    else if c == '*' then some Elem.Any
    else some (Elem.Lit c)

#guard parsePat "?" == [Elem.Any]
#guard parsePat "*" == [Elem.Wild]