def sumList (xs : List Int) : Int :=
  match xs with
  | []      => 0
  | x :: xs => x + sumList xs

#eval sumList [1, 3, 5]
