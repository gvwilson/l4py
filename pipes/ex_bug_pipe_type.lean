-- Fix: this pipeline has a type mismatch
-- the shout function expects a String, but it's being fed an Int
def double (x : Int) : Int := x * 2
def shout (s : String) : String := s.toUpper

#eval 5 |> double |> shout
