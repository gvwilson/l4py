-- Write: add a lean_lib target called 'MathLib'
import Lake
open Lake DSL

package «myproject» where
  name := "myproject"

lean_exe «myproject» where
  root := `Main

-- TODO: add a lean_lib target named 'MathLib'
