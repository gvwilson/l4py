-- Pattern matching must handle every constructor
inductive Shape where
  | circle (radius : Float)
  | rect (width : Float) (height : Float)

def area : Shape → Float
  | Shape.circle r => 3.14159 * r * r
  | Shape.rect w h => w * h

#eval area (Shape.circle 3.0)
#eval area (Shape.rect 2.0 5.0)
