-- ctxGet returns Option TVal, but this code treats it as a String. Fix it.
abbrev Context := List (String × TVal)

inductive TVal where | Str (s : String) | List (items : List Context)

def ctxGet (ctx : Context) (name : String) : Option TVal :=
  (ctx.find? (·.1 == name)).map (·.2)

def getGreeting (ctx : Context) : String :=
  let val := ctxGet ctx "user"
  s!"Hello, {val}!"

#guard getGreeting [("user", TVal.Str "Alice")] == "Hello, Alice!"
#guard getGreeting [] == "Hello, unknown!"