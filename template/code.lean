-- mccole: tval
-- Values that can appear in a template context
inductive TVal where
  | Str  : String → TVal
  | List : List (List (String × TVal)) → TVal
  deriving Repr
-- mccole: /tval

-- mccole: context
-- A context maps variable names to template values
abbrev Context := List (String × TVal)
-- mccole: /context

-- mccole: tnode
-- Template abstract syntax tree nodes
inductive TNode where
  | TText : String → TNode                    -- literal text
  | TVar  : String → TNode                    -- {{ var }}
  | TLoop : String → TNode → TNode            -- {% for x in list %} body {% end %}
  | TIf   : String → TNode → TNode → TNode   -- {% if var %} then {% else %} else {% end %}
  | TSeq  : List TNode → TNode                -- sequence of nodes
  deriving Repr
-- mccole: /tnode

-- mccole: ctx-get
-- Look up a variable in the context
def ctxGet (ctx : Context) (name : String) : Option TVal :=
  (ctx.find? (·.1 == name)).map (·.2)
-- mccole: /ctx-get

-- mccole: expand
-- Expand a template node to a string using the given context
def expand (ctx : Context) : TNode → String
  | TNode.TText s     => s
  | TNode.TVar name   =>
      match ctxGet ctx name with
      | some (TVal.Str s) => s
      | _                 => ""
  | TNode.TLoop listName body =>
      match ctxGet ctx listName with
      | some (TVal.List items) =>
          items.foldl (init := "") fun acc itemCtx =>
            acc ++ expand (itemCtx ++ ctx) body
      | _ => ""
  | TNode.TIf varName thenNode elseNode =>
      match ctxGet ctx varName with
      | some (TVal.Str s) => if s.isEmpty then expand ctx elseNode
                             else expand ctx thenNode
      | some (TVal.List l) => if l.isEmpty then expand ctx elseNode
                              else expand ctx thenNode
      | none => expand ctx elseNode
  | TNode.TSeq nodes  => nodes.foldl (init := "") fun acc n => acc ++ expand ctx n
-- mccole: /expand

-- mccole: tests
-- Tests ----------------------------------------------------------------

-- Simple variable substitution: "Hello, {{ name }}!" with name="World"
def helloTmpl : TNode :=
  TNode.TSeq [TNode.TText "Hello, ", TNode.TVar "name", TNode.TText "!"]

#guard expand [("name", TVal.Str "World")] helloTmpl == "Hello, World!"

-- Loop: <ul>{% for item in items %}<li>{{ x }}</li>{% end %}</ul>
def listTmpl : TNode :=
  TNode.TSeq [
    TNode.TText "<ul>",
    TNode.TLoop "items"
      (TNode.TSeq [TNode.TText "<li>", TNode.TVar "x", TNode.TText "</li>"]),
    TNode.TText "</ul>"
  ]

def listCtx : Context := [
  ("items", TVal.List [[("x", TVal.Str "apples")], [("x", TVal.Str "bananas")]])
]

#guard expand listCtx listTmpl == "<ul><li>apples</li><li>bananas</li></ul>"

-- Conditional: {% if show %}visible{% else %}hidden{% end %}
def ifTmpl : TNode :=
  TNode.TIf "show" (TNode.TText "visible") (TNode.TText "hidden")

#guard expand [("show", TVal.Str "yes")] ifTmpl == "visible"
#guard expand [("show", TVal.Str "")]    ifTmpl == "hidden"
#guard expand []                         ifTmpl == "hidden"

-- Nested: variable inside conditional inside sequence
def nestedTmpl : TNode :=
  TNode.TSeq [
    TNode.TText "Status: ",
    TNode.TIf "active"
      (TNode.TSeq [TNode.TText "ON (", TNode.TVar "user", TNode.TText ")"])
      (TNode.TText "OFF")
  ]

#guard expand [("active", TVal.Str "1"), ("user", TVal.Str "admin")] nestedTmpl
        == "Status: ON (admin)"
#guard expand [("active", TVal.Str "")] nestedTmpl
        == "Status: OFF"
-- mccole: /tests

-- mccole: hello
-- Render a simple hello template
def helloTemplate : TNode :=
  TNode.TSeq [
    TNode.TText "<h1>Welcome, ",
    TNode.TVar "user",
    TNode.TText "!</h1>",
    TNode.TText "\n",
    TNode.TText "<p>You have ",
    TNode.TVar "count",
    TNode.TText " items.</p>"
  ]

def helloCtx : Context := [
  ("user", TVal.Str "Alice"),
  ("count", TVal.Str "3")
]
-- mccole: /hello

-- mccole: main
-- Entry point: render a template and print the result
-- Run with: lean --run template/code.lean
def main : IO Unit := do
  let output := expand helloCtx helloTemplate
  IO.println output
  IO.println "Done."
-- mccole: /main