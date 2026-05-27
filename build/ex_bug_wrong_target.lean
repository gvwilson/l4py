-- Fix: this target should be an executable, not a library
import Lake
open Lake DSL

package «app» where
  name := "app"

lean_lib «app» where
  root := `Main
