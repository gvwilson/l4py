-- Write a Summarizable type class with a `summary` method that returns
-- a one-line summary of a value. Then write an instance for String that
-- returns the first 10 characters followed by "..." if the string is longer.

class Summarizable (α : Type) where
  summary : α → String

-- TODO: write an instance for String

#guard Summarizable.summary "hello" == "hello"
#guard Summarizable.summary "hello world this is long" == "hello worl..."
#guard Summarizable.summary "" == ""
