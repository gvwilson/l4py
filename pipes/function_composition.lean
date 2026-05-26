def double (x : Int) : Int := x * 2
def addOne (x : Int) : Int := x + 1

-- compose two functions with ∘ (type \comp)
def addThenDouble : Int → Int := double ∘ addOne

-- the composed function is a new function
#eval addThenDouble 3

-- compose more than two with parentheses
def shout (s : String) : String := s.toUpper
def greet (name : String) : String := s!"Hello, {name}"

def excitedGreeting : String → String := shout ∘ greet

#eval excitedGreeting "world"
