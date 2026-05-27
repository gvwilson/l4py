-- Fix: srcDir points to the wrong location
-- The .lean files are in 'src/' but lakefile says 'source/'
import Lake
open Lake DSL

package «myapp» where
  name := "myapp"

lean_exe «myapp» where
  root := `Main
  srcDir := "source"
