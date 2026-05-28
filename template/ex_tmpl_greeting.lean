-- Build a TNode tree for the template "Hello, {{ name }}!" and test it
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

def greetingTmpl : TNode :=
  TNode.TSeq []

#guard expand [("name", TVal.Str "World")] greetingTmpl == "Hello, World!"