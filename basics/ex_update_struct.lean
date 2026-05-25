structure Point where
  x : Float
  y : Float

-- Write a function 'moveRight' that takes a Point
-- and returns a new Point with x increased by 1.0.
def moveRight (p : Point) : Point :=
  p

#guard moveRight { x := 3.0, y := 0.0 } == { x := 4.0, y := 0.0 }
#guard moveRight { x := 0.0, y := 5.0 } == { x := 1.0, y := 5.0 }
