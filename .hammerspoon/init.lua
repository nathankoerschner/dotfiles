hs.window.animationDuration = 0
local application = require("hs.application")
super = { "ctrl", "alt", "cmd", "shift" }

local appList = {
    ["J"] = "iTerm2",
	["K"] = "Firefox", -- B for browse
    ["L"] = "Slack",
	["M"] = "Calendar",
}

local module = {}
for k, v in pairs(appList) do
	module["app_" .. v] = hs.hotkey.bind(super, k, function()
		application.launchOrFocus(v)
	end)
end

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
