-- Write: implement greet using string interpolation
namespace Greeter

def greet (name : String) : String :=
  ""  -- replace with s!"Hello, {name}!"

end Greeter

#eval Greeter.greet "world"
