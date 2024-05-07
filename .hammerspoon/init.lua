hs.window.animationDuration = 0
local application = require("hs.application")
super = { "ctrl", "alt", "cmd", "shift" }

local appList = {
    ["J"] = "iTerm",
	["K"] = "Firefox",
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
	resizeUp = "I",
	resizeDown = "U",
	resizeLeft = "Y",
	resizeRight = "O",
	showDesktop = "o",
	cascadeAllWindows = ",",
	cascadeAppWindows = ".",
	snapToGrid = "/",
	maximizeWindow = "P",
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
