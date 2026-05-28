-- Fix the literal matching: it always returns true
def matchLit (c c' : Char) : Bool :=
  true

#guard matchLit 'a' 'a'
#guard !matchLit 'a' 'b'