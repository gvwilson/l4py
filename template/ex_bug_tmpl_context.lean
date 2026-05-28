-- Loop context should shadow outer context, but this puts outer first. Fix it.
abbrev Context := List (String × TVal)

inductive TVal where | Str (s : String) | List (items : List Context)

inductive TNode where
  | TText (s : String) | TVar (name : String)
  | TLoop (name : String) (body : TNode) | TSeq (nodes : List TNode)

def ctxGet (ctx : Context) (name : String) : Option TVal :=
  (ctx.find? (·.1 == name)).map (·.2)

def expand (ctx : Context) : TNode → String
  | TNode.TText s => s
  | TNode.TVar name =>
      match ctxGet ctx name with
      | some (TVal.Str s) => s
      | _ => ""
  | TNode.TLoop listName body =>
      match ctxGet ctx listName with
      | some (TVal.List items) =>
          items.foldl (init := "") fun acc itemCtx =>
            acc ++ expand (ctx ++ itemCtx) body
      | _ => ""
  | TNode.TSeq nodes => nodes.foldl (init := "") fun acc n => acc ++ expand ctx n

def tmpl : TNode :=
  TNode.TSeq [
    TNode.TText "outer: ",
    TNode.TVar "x",
    TNode.TText " | ",
    TNode.TLoop "items" (TNode.TVar "x")
  ]

-- Outer x is "outer", inner x is "a". The loop should print "a", not "outer".
def ctx : Context := [("x", TVal.Str "outer"), ("items", TVal.List [[("x", TVal.Str "a")]])]

#guard expand ctx tmpl == "outer: outer | a"