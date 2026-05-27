-- Contents of lakefile.lean created by: lake new MyProject
import Lake
open Lake DSL

package «MyProject» where
  name := "MyProject"

lean_exe «MyProject» where
  root := `Main
