namespace Colors

def red : String := "#FF0000"
def green : String := "#00FF00"

end Colors

-- open brings all names into scope
-- like Python's: from module import *
open Colors

#eval red
#eval green
