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
	["j"] = "Terminal",
	["k"] = "Safari",
	["u"] = "Calendar",
	["i"] = "Finder",
	["o"] = "Microsoft Excel",
	["1"] = "1Password",
	["t"] = "Things3",
}
local urlList = {
	["s"] = "https://app.slack.com/client/T3Z6DPS4V/activity",
	["h"] = "https://chatgpt.com/",
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






-- Sends "escape" if "caps lock" is held for less than .2 seconds, and no other keys are pressed.

local send_escape = false
local last_mods = {}
local control_key_timer = hs.timer.delayed.new(0.2, function()
    send_escape = false
end)

hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(evt)
    local new_mods = evt:getFlags()
    if last_mods["ctrl"] == new_mods["ctrl"] then
        return false
    end
    if not last_mods["ctrl"] then
        last_mods = new_mods
        send_escape = true
        control_key_timer:start()
    else
        if send_escape then
            hs.eventtap.keyStroke({}, "escape")
        end
        last_mods = new_mods
        control_key_timer:stop()
    end
    return false
end):start()


hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(evt)
    send_escape = false
    return false
end):start()
