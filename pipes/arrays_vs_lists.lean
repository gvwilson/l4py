-- Arrays: contiguous memory, O(1) indexed access, fixed-size after creation
def nums : Array Int := #[10, 20, 30, 40, 50]
#eval nums[2]!          -- 30, direct O(1) access
#eval nums.size         -- 5

-- Lists: singly-linked, O(1) head/tail, O(n) indexed access
def items : List Int := [10, 20, 30, 40, 50]
#eval items.head!       -- 10, O(1)
#eval items.length      -- 5, O(n): traverses the whole list

-- Converting between them
#eval items.toArray     -- List → Array
#eval nums.toList       -- Array → List

-- Use Array when you need random access or interop with IO functions
-- Use List when you need pattern matching with :: or cons-style recursion
