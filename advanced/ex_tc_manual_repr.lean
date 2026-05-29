-- Instead of deriving Repr, write a manual Display instance for the
-- TrafficLight type. The `display` method should return the colour name.

class Display (α : Type) where
  display : α → String

inductive TrafficLight where
  | Red | Yellow | Green

-- TODO: write a manual instance of Display for TrafficLight
-- (do NOT use deriving)

#guard Display.display TrafficLight.Red == "red"
#guard Display.display TrafficLight.Yellow == "yellow"
#guard Display.display TrafficLight.Green == "green"
