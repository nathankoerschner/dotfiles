hs.window.animationDuration = 0
super = { "ctrl", "alt", "cmd" }

-- -- Keybindings for window management
-- winmanHotkeys = {
	-- 	resizeUp = "K",
	-- 	resizeDown = "J",
	-- 	resizeLeft = "H",
	-- 	resizeRight = "L",
	-- 	showDesktop = "O",
	-- 	cascadeAllWindows = ",",
	-- 	cascadeAppWindows = ".",
	-- 	snapToGrid = "/",
	-- 	maximizeWindow = ";",
	-- 	moveUp = "Up",
	-- 	moveDown = "Down",
	-- 	moveLeft = "Left",
	-- 	moveRight = "Right",
	-- }
	-- require("winman") -- Window management
	
	-- Required libraries and modules
	-- require "screenhop" -- Screen hopping -- haven't been using this
	require("readline") -- Readline style bindings
	require("righties")
	require('yabai')
	
-- Load and start extensions
local hints = require("hs.hints")
hs.loadSpoon("ControlEscape")
spoon.ControlEscape:start()

-- Hotkey bindings
hs.hotkey.bind(super, "Space", function()
	hs.hints.windowHints()
end)
