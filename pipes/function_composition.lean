def double (x : Int) : Int := x * 2
def addOne (x : Int) : Int := x + 1

-- compose two functions with ∘ (type \comp)
def addThenDouble : Int → Int := double ∘ addOne

-- the composed function is a new function
#eval addThenDouble 3

-- compose more than two with parentheses
def shout (s : String) : String := s.toUpper
def greet (name : String) : String := s!"Hello, {name}"
def addBang (s : String) : String := s ++ "!!"

-- parens bound the lambda body so ∘ connects two functions, not terms
-- without them: fun s => s ++ "!!" ∘ shout parses as fun s => s ++ ("!!" ∘ shout)
-- which is a type error: "!!" is a String, not a function
def shoutThenBang : String → String := (fun s => s ++ "!!") ∘ shout
#eval shoutThenBang "hello"

-- parens surround the whole composition before applying to an argument
-- without them: "world" binds to greet first, giving a String where ∘ expects a function
#eval (addBang ∘ shout ∘ greet) "world"
