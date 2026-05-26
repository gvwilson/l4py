-- Write: compose three functions with ∘
-- create a pipeline that: uppercases, reverses, then adds "!!"
def upper (s : String) : String := s.toUpper
def reverse (s : String) : String :=
  String.ofList (s.toList.reverse)
def exclaim (s : String) : String := s ++ "!!"

-- replace with composition of all three
def shoutReverse : String → String := upper

#eval shoutReverse "hello"
#guard shoutReverse "hello" == "OLLEH!!"
