def pair : Int × Int := (10, 20)

#eval pair.1
#eval pair.2

def swap (p : Int × Int) : Int × Int :=
  let (x, y) := p
  (y, x)

#eval swap pair
