def double (x : Int) : Int := x * 2
def addOne (x : Int) : Int := x + 1

-- without pipes: nested calls read inside-out
#eval double (addOne 3)

-- with |> : left-to-right, step by step
#eval 3 |> addOne |> double

-- works with any data type
def greet (name : String) : String := s!"Hello, {name}"
def shout (s : String) : String := s.toUpper

#eval "world" |> greet |> shout
