-- This function should sum all numbers in a tree, but the match
-- is missing the leaf case. Fix it.
inductive IntTree where
  | leaf : Int → IntTree
  | node : IntTree → IntTree → IntTree

def totalSum (t : IntTree) : Int :=
  match t with
  | IntTree.node left right => totalSum left + totalSum right
