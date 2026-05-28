-- An empty string "" should be falsy, but this treats it as truthy. Fix it.
abbrev Context := List (String × TVal)

inductive TVal where | Str (s : String) | List (items : List Context)

inductive TNode where
  | TText (s : String) | TIf (name : String) (t e : TNode)

def ctxGet (ctx : Context) (name : String) : Option TVal :=
  (ctx.find? (·.1 == name)).map (·.2)

def expand (ctx : Context) : TNode → String
  | TNode.TText s => s
  | TNode.TIf varName thenNode elseNode =>
      match ctxGet ctx varName with
      | some (TVal.Str s) => expand ctx thenNode
      | _ => expand ctx elseNode

def tmpl : TNode := TNode.TIf "flag" (TNode.TText "ON") (TNode.TText "OFF")

#guard expand [("flag", TVal.Str "yes")] tmpl == "ON"
#guard expand [("flag", TVal.Str "")]    tmpl == "OFF"
#guard expand []                          tmpl == "OFF"