-- A sum type where each constructor carries different data
inductive Shape where
  | circle (radius : Float)
  | rect (width : Float) (height : Float)
deriving Repr

def s1 : Shape := Shape.circle 3.0
def s2 : Shape := Shape.rect 2.0 5.0

#eval s1
#eval s2
