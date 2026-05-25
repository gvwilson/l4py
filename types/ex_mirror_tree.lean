-- Write 'mirrorTree' that swaps left and right subtrees of every node.
-- A leaf is unchanged.
inductive Tree (α : Type) where
  | leaf : α → Tree α
  | node : Tree α → Tree α → Tree α
deriving BEq, Repr

def mirrorTree (t : Tree α) : Tree α :=
  t

#guard mirrorTree (Tree.leaf 1) == Tree.leaf 1
#guard mirrorTree (Tree.node (Tree.leaf "a") (Tree.leaf "b")) == Tree.node (Tree.leaf "b") (Tree.leaf "a")
