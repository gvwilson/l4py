def firstElement (xs : List Int) : Option Int :=
  match xs with
  | []     => Option.none
  | x :: _ => Option.some x

#eval firstElement [10, 20, 30]
#eval firstElement []

def firstOrZero (xs : List Int) : Int :=
  match firstElement xs with
  | Option.none   => 0
  | Option.some x => x

#eval firstOrZero [10, 20, 30]
#eval firstOrZero []
