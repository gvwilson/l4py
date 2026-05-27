import Lake
open Lake DSL

package «myproject» where
  name := "myproject"

-- A library target: compiled but not directly runnable
lean_lib «MathUtils» where
  srcDir := "lib"

-- An executable target: produces a runnable binary
lean_exe «myproject» where
  root := `Main
