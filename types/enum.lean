-- A sum type with no data: just labels
inductive Season where
  | spring | summer | fall | winter
deriving BEq, Repr

#eval Season.summer
#eval Season.summer == Season.winter
#eval Season.summer == Season.summer
