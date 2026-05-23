structure Point where
  x : Float
  y : Float

def origin : Point := { x := 0.0, y := 0.0 }
def here : Point := { x := 3.0, y := 4.0 }

#eval origin.x
#eval here.y

def distance (p : Point) : Float :=
  Float.sqrt (p.x * p.x + p.y * p.y)

#eval distance here
