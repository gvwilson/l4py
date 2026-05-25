-- Write a function 'swap' that takes (Int, String)
-- and returns (String, Int) with the elements exchanged.
def swap (p : Int × String) : String × Int :=
  ("", 0)

#guard swap (42, "hello") == ("hello", 42)
#guard swap (7, "seven") == ("seven", 7)
