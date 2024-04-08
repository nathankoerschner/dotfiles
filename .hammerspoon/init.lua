hs.window.animationDuration = 0
super = { "ctrl", "alt", "cmd" }

-- -- Keybindings for window management
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
		moveRight = "Right",
	}
	require("winman")
	require("righties")
-- Load and start extensions
hs.loadSpoon("ControlEscape")
spoon.ControlEscape:start()
