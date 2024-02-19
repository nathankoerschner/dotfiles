hs.window.animationDuration = 0
super = {"ctrl", "alt", "cmd"}

-- Keybindings for window management
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

-- Required libraries and modules
require "winman" -- Window management
require "screenhop" -- Screen hopping
require "readline" -- Readline style bindings
require "righties"

-- Load and start extensions
local hints = require "hs.hints"
hs.loadSpoon("ControlEscape")
spoon.ControlEscape:start()

-- Hotkey bindings
hs.hotkey.bind(super, "Space", function()
  hs.hints.windowHints()
end) 
