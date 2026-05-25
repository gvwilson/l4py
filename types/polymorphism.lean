-- A polymorphic binary tree: leaves can be any type α
inductive Tree (α : Type) where
  | leaf : α → Tree α
  | node : Tree α → Tree α → Tree α
deriving Repr

-- A function that works for trees of any type
def countLeaves (t : Tree α) : Nat :=
  match t with
  | Tree.leaf _ => 1
  | Tree.node left right => countLeaves left + countLeaves right

-- A tree of numbers
def numTree : Tree Nat :=
  Tree.node
    (Tree.node
      (Tree.leaf 1)
      (Tree.leaf 2))
    (Tree.leaf 3)

#eval numTree
#eval countLeaves numTree
