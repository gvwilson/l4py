-- reverse.foldl produces backward output. Fix it.
abbrev Context := List (String × TVal)

inductive TVal where | Str (s : String) | List (items : List Context)

inductive TNode where
  | TText (s : String) | TSeq (nodes : List TNode)

def expand (ctx : Context) : TNode → String
  | TNode.TText s => s
  | TNode.TSeq nodes => nodes.reverse.foldl (init := "") fun acc n => acc ++ expand ctx n

def tmpl : TNode :=
  TNode.TSeq [TNode.TText "A", TNode.TText "B", TNode.TText "C"]

#guard expand [] tmpl == "ABC"