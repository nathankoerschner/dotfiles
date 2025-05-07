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

---------------------------------------
---
---
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "t", function()
  -- Step 1: Create a new Chrome window
  hs.osascript.applescript([[
    tell application "Google Chrome"
      activate
      make new window
    end tell
  ]])

  -- Step 2: After delay, set URL and move window
  hs.timer.doAfter(1.0, function()
    -- Now set the URL
    hs.osascript.applescript([[
      tell application "Google Chrome"
        set URL of active tab of front window to "https://monkeytype.com"
      end tell
    ]])

    -- Then reposition the window
    local chrome = hs.appfinder.appFromName("Google Chrome")
    if not chrome then return end

    local win = chrome:mainWindow()
    if not win then return end

    local screenFrame = win:screen():frame()
    local winWidth = screenFrame.w / 2
    local winHeight = screenFrame.h / 2

    win:setFrame({
      x = screenFrame.x,
      y = screenFrame.y + screenFrame.h - winHeight,
      w = winWidth,
      h = winHeight
    })
  end)
end)


------------ Alternate Window Shortcut ------------

-- Store the current and previous window
local currentWindow = nil
local previousWindow = nil

-- Function to update window history
local function updateWindowHistory()
	local win = hs.window.focusedWindow()
	if win and win ~= currentWindow then
		previousWindow = currentWindow
		currentWindow = win
	end
end

-- Set up window filter to track window focus changes
local windowFilter = hs.window.filter.new()
windowFilter:subscribe(hs.window.filter.windowFocused, updateWindowHistory)

-- Function to switch to the previous window
local function switchToPreviousWindow()
	if previousWindow and previousWindow:isVisible() then
		previousWindow:focus()
	end
end


hs.hotkey.bind({"cmd", "alt", "ctrl"}, "h", function()
  hs.reload()
end)
