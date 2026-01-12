-- TODO:
-- https://github.com/zzamboni/dot-hammerspoon/blob/master/init.org#url-dispatching-to-site-specific-browsers
--
--https://github.com/zzamboni/dot-hammerspoon/blob/master/init.org#caffeine-control-systemdisplay-sleep
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

local module = {}
local appList = {
	["n"] = "Notes",
    ["l"] = "Timelines",
	["f"] = "Google Chrome",
	["k"] = "Calendar",
    ["j"] = "Ghostty",
	["s"] = "Slack",
	["r"] = "Reminders",
    ["1"] = "1Password",
}
local urlList = {
	["a"] = "https://claude.ai/new",
	["0"] = "https://calendar.google.com",
}

for k, v in pairs(urlList) do
	module["app_" .. v] = hs.hotkey.bind({ "ctrl", "cmd" }, k, function()
		hs.execute("open " .. v)
	end)
end

for k, v in pairs(appList) do
	module["app_" .. v] = hs.hotkey.bind({ "ctrl", "cmd" }, k, function()
		hs.application.launchOrFocus(v)
	end)
end

-- MonkeyType launcher with custom window size
hs.hotkey.bind({ "ctrl", "cmd" }, "t", function()
	-- Open monkeytype in a new Chrome window
	local task = hs.task.new("/usr/bin/open", nil, { "-na", "Google Chrome", "--args", "--new-window", "https://monkeytype.com/" })
	task:start()

	-- Wait for the new window to appear, then resize and center it
	hs.timer.doAfter(0.5, function()
		local chrome = hs.application.find("Google Chrome")
		if chrome then
			local win = chrome:focusedWindow()
			if win then
				local screen = win:screen()
				local screenFrame = screen:frame()

				-- Calculate 50% width, 60% height, centered
				local newWidth = screenFrame.w * 0.5
				local newHeight = screenFrame.h * 0.6
				local newX = screenFrame.x + (screenFrame.w - newWidth) / 2
				local newY = screenFrame.y + (screenFrame.h - newHeight) / 2

				win:setFrame(hs.geometry.rect(newX, newY, newWidth, newHeight))
			end
		end
	end)
end)

-- Inspired by https://github.com/jasoncodes/dotfiles/blob/master/hammerspoon/control_escape.lua
-- You'll also have to install Karabiner Elements and map caps_lock to left_control there
len = function(t)
	local length = 0
	for k, v in pairs(t) do
		length = length + 1
	end
	return length
end

send_escape = false
prev_modifiers = {}

modifier_handler = function(evt)
	-- evt:getFlags() holds the modifiers that are currently held down
	local curr_modifiers = evt:getFlags()

	if curr_modifiers["ctrl"] and len(curr_modifiers) == 1 and len(prev_modifiers) == 0 then
		-- We need this here because we might have had additional modifiers, which
		-- we don't want to lead to an escape, e.g. [Ctrl + Cmd] —> [Ctrl] —> [ ]
		send_escape = true
	elseif prev_modifiers["ctrl"] and len(curr_modifiers) == 0 and send_escape then
		send_escape = false
		hs.eventtap.keyStroke({}, "ESCAPE")
	else
		send_escape = false
	end
	prev_modifiers = curr_modifiers
	return false
end

-- Call the modifier_handler function anytime a modifier key is pressed or released
modifier_tap = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, modifier_handler)
modifier_tap:start()

-- If any non-modifier key is pressed, we know we won't be sending an escape
non_modifier_tap = hs.eventtap
	.new({ hs.eventtap.event.types.keyDown }, function(evt)
		send_escape = false
		return false
	end)
	:start()


hs.hotkey.bind({"cmd", "alt", "ctrl"}, "h", function()
  hs.reload()
end)
