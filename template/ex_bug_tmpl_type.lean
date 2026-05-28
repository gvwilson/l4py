-- ctxGet returns Option TVal, not Option String. Fix the type mismatch.
abbrev Context := List (String × TVal)

inductive TVal where | Str (s : String) | List (items : List Context)

def ctxGet (ctx : Context) (name : String) : Option TVal :=
  (ctx.find? (·.1 == name)).map (·.2)

def lookupString (ctx : Context) (name : String) : String :=
  match ctxGet ctx name with
  | some s => s
  | none => ""

#guard lookupString [("x", TVal.Str "hello")] "x" == "hello"
#guard lookupString [] "x" == ""