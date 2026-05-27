import Lake
open Lake DSL

package «binary» where
  name := "binary"

lean_lib «code»

lean_exe «example» where
  root := `example
