import Lake
open Lake DSL

package «build» where
  name := "build"
  packagesDir := "../.lake/packages"

lean_lib «MyProject»

lean_exe «import_module» where
  root := `import_module
