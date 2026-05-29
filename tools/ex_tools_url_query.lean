-- Write a pure function that parses the query string portion of a URL
-- into a list of (key, value) pairs. The query string is the part after "?".
-- e.g., "?name=Ada&lang=lean" → [("name", "Ada"), ("lang", "lean")]
-- Handle missing values: "?flag" should produce [("flag", "")].
-- Return an empty list if there is no query string.

def parseQuery (url : String) : List (String × String) :=
  []  -- TODO

#guard parseQuery "http://example.com?name=Ada&lang=lean" ==
  [("name", "Ada"), ("lang", "lean")]

#guard parseQuery "http://example.com/?key=val" ==
  [("key", "val")]

#guard parseQuery "http://example.com?flag" ==
  [("flag", "")]

#guard parseQuery "http://example.com" == []

#guard parseQuery "http://example.com?a=1&b=2&c=3" ==
  [("a", "1"), ("b", "2"), ("c", "3")]
