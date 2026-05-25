-- 'deriving' generates boilerplate for common type classes
inductive Color where
  | red | green | blue
deriving BEq, Repr

-- 'deriving BEq' lets us compare values with ==
#eval Color.red == Color.green
#eval Color.red == Color.red

-- 'deriving Repr' makes #eval display values readably
#eval Color.blue
