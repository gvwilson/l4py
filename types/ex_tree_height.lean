-- Write a function 'height' that computes the height of a Tree.
-- The height of a leaf is 0; a node's height is 1 + max of children.
inductive Tree (α : Type) where
  | leaf : α → Tree α
  | node : Tree α → Tree α → Tree α
deriving Repr

def height (t : Tree α) : Nat :=
  0

#guard height (Tree.leaf "x") == 0
#guard height (Tree.node (Tree.leaf "a") (Tree.leaf "b")) == 1
#guard height (Tree.node (Tree.node (Tree.leaf "a") (Tree.leaf "b")) (Tree.leaf "c")) == 2
