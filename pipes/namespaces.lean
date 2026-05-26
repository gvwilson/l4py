-- namespaces prevent name collisions
-- like Python's modules: math.sin vs math.cos

namespace Greeting

def hello (name : String) : String := s!"Hello, {name}"

end Greeting

namespace Farewell

def hello (name : String) : String := s!"Goodbye, {name}"

end Farewell

-- use the fully-qualified name
#eval Greeting.hello "world"
#eval Farewell.hello "world"
