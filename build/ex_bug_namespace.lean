-- Fix: the function is defined in namespace 'Foo' but called as 'Bar.func'
namespace Foo

def func : String := "from Foo"

end Foo

def main : IO Unit := do
  IO.println Bar.func
