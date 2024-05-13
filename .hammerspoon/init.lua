hs.window.animationDuration = 0
super = { "alt", "cmd" }

-- -- Keybindings for window management
winmanHotkeys = {
	resizeDown = "j",
	resizeUp = "k",
	resizeRight = "l",
	resizeLeft = "h",
	showDesktop = "o",
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

-- Load and start extensions
hs.loadSpoon("ControlEscape")
spoon.ControlEscape:start()

local appList = {
	["j"] = "iTerm",
	["k"] = "Firefox",
	["l"] = "Slack",
	["u"] = "Calendar",
}

local module = {}
for k, v in pairs(appList) do
	module["app_" .. v] = hs.hotkey.bind({ "ctrl", "cmd" }, k, function()
		hs.application.launchOrFocus(v)
	end)
end
