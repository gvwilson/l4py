-- A sum type that can hold either a String or an Int
inductive StringOrInt where
  | str : String → StringOrInt
  | num : Int → StringOrInt
deriving Repr

-- Construct a value of each kind
def greeting : StringOrInt := StringOrInt.str "hello"
def answer : StringOrInt := StringOrInt.num 42

#eval greeting
#eval answer

-- A list can hold a mix of both
def mixed : List StringOrInt := [
  StringOrInt.str "hello",
  StringOrInt.num 42,
  StringOrInt.str "world"
]

#eval mixed

-- Use pattern matching to extract the value
def describe (x : StringOrInt) : String :=
  match x with
  | StringOrInt.str s => s!"string: \"{s}\""
  | StringOrInt.num n => s!"number: {n}"

#eval describe greeting
#eval describe answer
