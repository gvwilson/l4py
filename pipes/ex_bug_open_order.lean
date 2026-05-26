-- Fix: the 'open' must come after the namespace definition
-- right now, open Colors happens before Colors exists

open Colors

namespace Colors
def red : String := "#FF0000"
end Colors

#eval red
