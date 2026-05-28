-- Build a template that repeats a word N times using a loop
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

def repeatTmpl : TNode :=
  TNode.TLoop "times" (TNode.TVar "word")

def ctx : Context := [
  ("times", TVal.List (List.replicate 3 [("word", TVal.Str "go")]))
]

#guard expand ctx repeatTmpl == "gogogo"