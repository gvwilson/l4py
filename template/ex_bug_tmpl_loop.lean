-- The loop only processes the first item instead of all. Fix it.
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
          match items.head? with
          | some itemCtx => expand (itemCtx ++ ctx) body
          | none => ""
      | _ => ""
  | TNode.TSeq nodes => nodes.foldl (init := "") fun acc n => acc ++ expand ctx n

def body : TNode := TNode.TSeq [TNode.TText "- ", TNode.TVar "x"]
def tmpl : TNode := TNode.TLoop "items" body
def ctx : Context := [("items", TVal.List [[("x", TVal.Str "a")], [("x", TVal.Str "b")]])]

#guard expand ctx tmpl == "- a- b"