import code

-- mccole: main
def main : IO Unit := do
  let values : List Value := [
    .int32 31,
    .int32 65,
    .str "hello",
    .str "Python"
  ]
  let packed := pack values
  IO.println s!"Packed {packed.size} bytes"
  let fmts : List Fmt := [.int32, .int32, .str, .str]
  match unpack fmts packed with
  | none    => IO.println "Error: unpack failed"
  | some vs =>
    for v in vs do
      match v with
      | .int32 n => IO.println s!"  int32: {n}"
      | .str s   => IO.println s!"  str:   {s}"
-- mccole: /main
