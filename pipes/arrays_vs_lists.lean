def nums : Array Int := #[10, 20, 30, 40, 50]
#eval nums[2]!          -- 30, direct O(1) access
#eval nums.size         -- 5

def items : List Int := [10, 20, 30, 40, 50]
#eval items.head!       -- 10, O(1)
#eval items.length      -- 5, O(n): traverses the whole list

#eval items.toArray     -- List → Array
#eval nums.toList       -- Array → List
