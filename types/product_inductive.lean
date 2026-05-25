-- A structure groups related values under one name
structure Point where
  x : Float
  y : Float
deriving Repr

-- A product type is really an inductive with a single constructor
inductive Point' where
  | mk (x : Float) (y : Float)
deriving Repr

def p1 : Point := { x := 1.0, y := 2.0 }
def p2 : Point' := Point'.mk 1.0 2.0

#eval p1
#eval p2
