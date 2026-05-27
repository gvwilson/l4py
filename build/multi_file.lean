-- Helpers.lean: a helper module in the same project
namespace Helpers

def greet (name : String) : String :=
  s!"Hello, {name}!"

def shout (msg : String) : String :=
  msg.toUpper ++ "!!!"

end Helpers
