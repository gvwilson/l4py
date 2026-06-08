-- Combine pattern matching on constructors with conditions inside each branch
inductive Shape where
  | circle (radius : Float)
  | rect (width : Float) (height : Float)
deriving Repr

def classify (s : Shape) : String :=
  match s with
  | Shape.circle r =>
    if r > 10.0 then "large circle" else "small circle"
  | Shape.rect w h =>
    if w == h then "square"
    else if w > h then "wide rectangle"
    else "tall rectangle"

#eval classify (Shape.circle 3.0)
#eval classify (Shape.circle 15.0)
#eval classify (Shape.rect 4.0 4.0)
#eval classify (Shape.rect 6.0 2.0)
#eval classify (Shape.rect 2.0 6.0)
