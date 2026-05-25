-- A tiny command language in three lines of type definition
inductive Cmd where
  | forward (steps : Nat)
  | turn (degrees : Int)
  | say (msg : String)
deriving Repr

-- Pattern matching plus recursion equals an interpreter
def run (cmds : List Cmd) : String :=
  match cmds with
  | [] => "done"
  | Cmd.say msg :: rest => s!"said '{msg}'; {run rest}"
  | Cmd.forward n :: rest => s!"moved {n}; {run rest}"
  | Cmd.turn d :: rest => s!"turned {d}°; {run rest}"

def program : List Cmd := [
  Cmd.forward 3,
  Cmd.say "hello",
  Cmd.turn 90
]

#eval run program
