-- Build a template that joins items with ", " but no trailing separator
inductive TVal where
  | Str (s : String)
  | List (items : List (List (String × TVal)))

abbrev Context := List (String × TVal)

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
            acc ++ expand (itemCtx ++ ctx) body
      | _ => ""
  | TNode.TSeq nodes => nodes.foldl (init := "") fun acc n => acc ++ expand ctx n

def joinTmpl : TNode :=
  TNode.TLoop "items" (TNode.TSeq [
    TNode.TVar "x",
    TNode.TText ", "
  ])

def ctx : Context := [
  ("items", TVal.List [
    [("x", TVal.Str "a")],
    [("x", TVal.Str "b")],
    [("x", TVal.Str "c")]
  ])
]

def renderWithJoin (ctx : Context) (tmpl : TNode) : String :=
  let raw := expand ctx tmpl
  if raw.isEmpty then raw else raw.dropRight 2

#guard renderWithJoin ctx joinTmpl == "a, b, c"