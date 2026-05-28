import Batteries
open Std

-- mccole: tval-map
-- Same value type as the association-list version — unchanged
inductive TVal where
  | Str  : String → TVal
  | List : List (List (String × TVal)) → TVal
  deriving Repr, BEq
-- mccole: /tval-map

-- mccole: hash-ctx
-- A HashMap context: O(1) lookup keyed by variable name
abbrev HashCtx := HashMap String TVal
-- mccole: /hash-ctx

-- mccole: tnode-map
-- Same template AST as the association-list version — unchanged
inductive TNode where
  | TText : String → TNode
  | TVar  : String → TNode
  | TLoop : String → TNode → TNode
  | TIf   : String → TNode → TNode → TNode
  | TSeq  : List TNode → TNode
  deriving Repr
-- mccole: /tnode-map

-- mccole: ctx-get-map
-- O(1) lookup: index directly into the HashMap
def ctxGet (ctx : HashCtx) (name : String) : Option TVal :=
  ctx[name]?
-- mccole: /ctx-get-map

-- mccole: expand-map
-- expand is structurally identical to the list version;
-- only the Context type and ctxGet implementation differ
def expand (ctx : HashCtx) : TNode → String
  | TNode.TText s     => s
  | TNode.TVar name   =>
      match ctxGet ctx name with
      | some (TVal.Str s) => s
      | _                 => ""
  | TNode.TLoop listName body =>
      match ctxGet ctx listName with
      | some (TVal.List items) =>
          items.foldl (init := "") fun acc itemCtx =>
            -- merge loop-iteration variables on top of outer context
            let inner := itemCtx.foldl (fun m (k, v) => m.insert k v) ctx
            acc ++ expand inner body
      | _ => ""
  | TNode.TIf varName thenNode elseNode =>
      match ctxGet ctx varName with
      | some (TVal.Str s)  => if s.isEmpty then expand ctx elseNode
                              else expand ctx thenNode
      | some (TVal.List l) => if l.isEmpty then expand ctx elseNode
                              else expand ctx thenNode
      | none => expand ctx elseNode
  | TNode.TSeq nodes  => nodes.foldl (init := "") fun acc n => acc ++ expand ctx n
-- mccole: /expand-map

-- mccole: tests-map
-- The same tests pass with the new context type
def helloTmpl : TNode :=
  TNode.TSeq [TNode.TText "Hello, ", TNode.TVar "name", TNode.TText "!"]

#guard expand (HashMap.ofList [("name", TVal.Str "World")]) helloTmpl == "Hello, World!"

def listTmpl : TNode :=
  TNode.TSeq [
    TNode.TText "<ul>",
    TNode.TLoop "items"
      (TNode.TSeq [TNode.TText "<li>", TNode.TVar "x", TNode.TText "</li>"]),
    TNode.TText "</ul>"
  ]

#guard expand
    (HashMap.ofList [("items", TVal.List
      [[("x", TVal.Str "apples")], [("x", TVal.Str "bananas")]])])
    listTmpl
  == "<ul><li>apples</li><li>bananas</li></ul>"

#guard expand (HashMap.ofList [("show", TVal.Str "yes")])
    (TNode.TIf "show" (TNode.TText "visible") (TNode.TText "hidden"))
  == "visible"

#guard expand ({} : HashCtx)
    (TNode.TIf "show" (TNode.TText "visible") (TNode.TText "hidden"))
  == "hidden"
-- mccole: /tests-map

-- mccole: main-map
def main : IO Unit := do
  let ctx : HashCtx := HashMap.ofList [
    ("user",  TVal.Str "Alice"),
    ("count", TVal.Str "3")
  ]
  let tmpl : TNode :=
    TNode.TSeq [
      TNode.TText "<h1>Welcome, ", TNode.TVar "user", TNode.TText "!</h1>\n",
      TNode.TText "<p>You have ", TNode.TVar "count", TNode.TText " items.</p>"
    ]
  IO.println (expand ctx tmpl)
  IO.println "Done."
-- mccole: /main-map
