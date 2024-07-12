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
	["j"] = "Terminal",
	["k"] = "Firefox",
	["u"] = "Calendar",
	["i"] = "Finder",
	["o"] = "Microsoft Excel",
	["1"] = "1Password",
	["s"] = "Slack",
	["a"] = "Anki",
}
local urlList = {
    ["n"] = "https://claude.ai/",
	["n"] = "https://claude.ai/",
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
    elseif prev_modifiers["ctrl"]  and len(curr_modifiers) == 0 and send_escape then
		send_escape = false
        hs.eventtap.keyStroke({}, "ESCAPE")
    else
        send_escape = false
	end
    prev_modifiers = curr_modifiers
	return false
end


-- Call the modifier_handler function anytime a modifier key is pressed or released
modifier_tap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, modifier_handler)
modifier_tap:start()


-- If any non-modifier key is pressed, we know we won't be sending an escape
non_modifier_tap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(evt)
    send_escape = false
    return false
end):start()



google_clipboard = function()
    -- Simulate cmd + c to copy highlighted text
    hs.eventtap.keyStroke({"cmd"}, "c")

    -- Wait a moment for the clipboard to update
    hs.timer.doAfter(0.2, function()
        local clipboard_content = hs.pasteboard.getContents()
        if clipboard_content and clipboard_content ~= "" then
            local url = "https://www.google.com/search?q=" .. hs.http.encodeForQuery(clipboard_content)
            hs.execute("open " .. url)
        else
            hs.alert.show("Clipboard is empty or invalid")
        end
    end)
end

hs.hotkey.bind({"cmd", "ctrl"}, "g", google_clipboard)

