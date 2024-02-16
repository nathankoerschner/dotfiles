hs.window.animationDuration = 0
super = {"ctrl", "alt", "cmd"}

winmanHotkeys = {
  resizeUp = "K", 
  resizeDown = "J", 
  resizeLeft = "H",
  resizeRight = "L", 
  showDesktop = "O", 
  cascadeAllWindows = ",",
  cascadeAppWindows = ".", 
  snapToGrid = "/", 
  maximizeWindow = ";",
  moveUp = "Up", 
  moveDown = "Down", 
  moveLeft = "Left", 
  moveRight = "Right"
}
require "winman" -- Window management --not as good as rectangle at the moment, so keeping with that
require "screenhop" -- Screen hopping


require "readline" -- Readline style bindings
local hints = require "hs.hints"


hs.loadSpoon("ControlEscape") -- Spoon from here: https://github.com/jasonrudolph/ControlEscape.spoon?tab=readme-ov-file
spoon.ControlEscape:start()


-- hs.hotkey.bind({"control", "alt"}, "Space", function()
--   hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
-- end)


hs.hotkey.bind(super, "Space", function()
    hs.hints.windowHints()
end) 
