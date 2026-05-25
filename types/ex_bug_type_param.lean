-- Count the leaves in a polymorphic tree. The return type
-- annotation is wrong. Fix it.
inductive Tree (α : Type) where
  | leaf : α → Tree α
  | node : Tree α → Tree α → Tree α

def countLeaves (t : Tree α) : String :=
  match t with
  | Tree.leaf _ => 1
  | Tree.node left right => countLeaves left + countLeaves right
