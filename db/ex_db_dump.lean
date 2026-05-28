-- Write a function that formats the entire log as a readable string
abbrev LogEntry := String × Option String
abbrev Log := List LogEntry

def dbDump (log : Log) : String :=
  ""

#guard dbDump [("x", some "1"), ("y", none)]
        == "x: 1\ny: (deleted)"
#guard dbDump [] == ""