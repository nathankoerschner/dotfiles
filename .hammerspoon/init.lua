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

local module = {}
local appList = {
	["j"] = "iTerm",
	["k"] = "Firefox",
	["u"] = "Calendar",
	["i"] = "Finder",
	["w"] = "Whatsapp",
	["o"] = "Microsoft Excel",
	["h"] = "ChatGPT",
	["1"] = "1Password",
}
local urlList = {
	["l"] = "https://app.slack.com/client/T3Z6DPS4V/activity",
}

for k, v in pairs(urlList) do
	module["app_" .. v] = hs.hotkey.bind({ "ctrl", "cmd" }, k, function()
		hs.execute("open " .. v)
	end)
end

for k, v in pairs(appList) do
	module["app_" .. v] = hs.hotkey.bind({ "ctrl", "cmd" }, k, function()
		hs.application.launchOrFocus(v)
		-- Get the currently focused window
		local win = hs.window.focusedWindow()
		if win then
			hs.grid.maximizeWindow(win)
		end

		-- Set the window to fullscreen
		win:setFrame(max)
	end)
end
