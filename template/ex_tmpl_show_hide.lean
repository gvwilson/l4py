-- Use TIf to show or hide a section based on "show_section"
inductive TVal where
  | Str (s : String)
  | List (items : List (List (String × TVal)))

abbrev Context := List (String × TVal)

inductive TNode where
  | TText (s : String) | TIf (name : String) (t e : TNode)

def ctxGet (ctx : Context) (name : String) : Option TVal :=
  (ctx.find? (·.1 == name)).map (·.2)

def expand (ctx : Context) : TNode → String
  | TNode.TText s => s
  | TNode.TIf varName thenNode elseNode =>
      match ctxGet ctx varName with
      | some (TVal.Str s) => if s.isEmpty then expand ctx elseNode
                             else expand ctx thenNode
      | _ => expand ctx elseNode

def showHideTmpl : TNode :=
  TNode.TIf "show_section" (TNode.TText "Section content") (TNode.TText "")

#guard expand [("show_section", TVal.Str "yes")] showHideTmpl == "Section content"
#guard expand [("show_section", TVal.Str "")]    showHideTmpl == ""
#guard expand []                                  showHideTmpl == ""