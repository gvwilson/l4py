-- A binary tree with strings at the leaves
inductive Tree where
  | leaf : String → Tree
  | node : Tree → Tree → Tree
deriving Repr

-- Build a tree
def myTree : Tree :=
  Tree.node
    (Tree.node
      (Tree.leaf "alpha")
      (Tree.leaf "beta"))
    (Tree.leaf "gamma")

#eval myTree

-- Calculate total length of all strings in the tree
def totalLength (t : Tree) : Nat :=
  match t with
  | Tree.leaf s => s.length
  | Tree.node left right => totalLength left + totalLength right

#eval totalLength myTree
