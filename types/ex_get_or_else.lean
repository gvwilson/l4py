-- Write 'getOrElse' that returns the value inside an Option if it's 'some',
-- or a default value if it's 'none'.
def getOrElse (opt : Option α) (default : α) : α :=
  default

#guard getOrElse (Option.some 5) 0 == 5
#guard getOrElse (Option.none : Option Int) 0 == 0
#guard getOrElse (Option.some "hello") "world" == "hello"
