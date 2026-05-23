-- Lean can infer the type from the value
def greeting := "hello"
def count := 42

#eval greeting
#eval count

-- Lean can infer the return type of a function
def double (val : Int) := val * 2

#eval double 7
