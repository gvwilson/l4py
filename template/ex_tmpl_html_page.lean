-- Build a template that renders a full HTML page with a title
inductive TVal where
  | Str (s : String)
  | List (items : List (List (String × TVal)))

abbrev Context := List (String × TVal)

inductive TNode where
  | TText (s : String) | TVar (name : String) | TSeq (nodes : List TNode)

def ctxGet (ctx : Context) (name : String) : Option TVal :=
  (ctx.find? (·.1 == name)).map (·.2)

def expand (ctx : Context) : TNode → String
  | TNode.TText s => s
  | TNode.TVar name =>
      match ctxGet ctx name with
      | some (TVal.Str s) => s
      | _ => ""
  | TNode.TSeq nodes => nodes.foldl (init := "") fun acc n => acc ++ expand ctx n

def htmlPageTmpl : TNode :=
  TNode.TSeq []

#guard expand [("title", TVal.Str "My Site")] htmlPageTmpl == "<html><body><h1>My Site</h1></body></html>"