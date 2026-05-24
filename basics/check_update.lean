#check 123

structure Point where
  x : Float
  y : Float

def origin : Point := { x := 0.0, y := 0.0 }
#check origin

def elsewhere : Point := {origin with x := 1.0 }
#eval elsewhere
