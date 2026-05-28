-- mccole: elements
-- Pattern elements for glob matching
inductive Elem where
  | Lit  : Char → Elem   -- literal character
  | Any  : Elem          -- match exactly one char  (?)
  | Wild : Elem          -- match zero or more chars (*)
  deriving Repr, BEq
-- mccole: /elements

-- mccole: glob-core
-- Chain of Responsibility: consume the matched prefix, return remaining chars.
-- Uses partial because Wild tries every suffix without a decreasing measure.
partial def glob : List Elem → List Char → Bool
  | [],             []        => true
  | [],             _         => false
  | Elem.Lit c :: ps, c' :: cs => c == c' && glob ps cs
  | Elem.Lit _ :: _,  []      => false
  | Elem.Any   :: ps, _ :: cs => glob ps cs
  | Elem.Any   :: _,  []      => false
  | Elem.Wild  :: [],  _      => true          -- * at end matches anything
  | Elem.Wild  :: ps,  cs     =>               -- try every split point
      (List.range (cs.length + 1)).any fun i =>
        glob ps (cs.drop i)
-- mccole: /glob-core

-- mccole: match-glob
-- Wrap glob for whole-string matching
def matchGlob (pat : List Elem) (s : String) : Bool :=
  glob pat s.toList
-- mccole: /match-glob

-- mccole: lit-pat
-- Helper to build a Lit element list from a string
def litPat (s : String) : List Elem := s.toList.map Elem.Lit
-- mccole: /lit-pat

-- mccole: parse-pat
-- Parse a glob pattern string into a list of Elem
def parsePat (s : String) : List Elem :=
  s.toList.filterMap fun c =>
    if c == '?' then some Elem.Any
    else if c == '*' then some Elem.Wild
    else some (Elem.Lit c)
-- mccole: /parse-pat

-- mccole: tests
-- Tests ---------------------------------------------------------------

-- Literal matching
#guard matchGlob (litPat "hello") "hello"
#guard !matchGlob (litPat "foo") "bar"

-- Wildcard at end
#guard matchGlob (litPat "hi" ++ [Elem.Wild]) "hiXYZ"
#guard matchGlob [Elem.Wild] ""
#guard matchGlob [Elem.Wild] "anything"

-- Wildcard at start
#guard matchGlob ([Elem.Wild] ++ litPat ".txt") "report.txt"
#guard !matchGlob ([Elem.Wild] ++ litPat ".txt") "report.csv"

-- Any single character
#guard matchGlob [Elem.Any] "x"
#guard !matchGlob [Elem.Any] ""
#guard !matchGlob [Elem.Any] "xy"

-- Combined patterns using parsePat
#guard matchGlob (parsePat "*.html") "index.html"
#guard matchGlob (parsePat "*.h*") "header.hpp"
#guard matchGlob (parsePat "*.h??") "header.hpp"
#guard !matchGlob (parsePat "*.h??") "main.cpp"
#guard matchGlob (parsePat "d?ta.*") "data.txt"
#guard !matchGlob (parsePat "d?ta.*") "date.txt"
-- mccole: /tests

-- mccole: main
-- Entry point: test a few patterns interactively
-- Run with: lean --run glob/code.lean
def main : IO Unit := do
  let patterns : List (String × String) := [
    ("*.lean", "basics/sum_list.lean"),
    ("*.lean", "types/option.lean"),
    ("*.out",  "basics/sum_list.out"),
    ("*.lean", "README.md")
  ]
  for (patStr, target) in patterns do
    let pat := parsePat patStr
    let result := if matchGlob pat target then "✓" else "✗"
    IO.println s!"{result} '{patStr}' matches '{target}'"
  IO.println "Done."
-- mccole: /main