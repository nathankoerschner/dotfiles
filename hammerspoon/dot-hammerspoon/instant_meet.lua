-- Instant Google Meet: Ctrl+Shift+Cmd+M creates a new Meet on the superbuilders
-- account and pastes its link where the cursor is (it also stays on the clipboard).
--
-- It opens meet.google.com/new in the background in the Chrome profile signed in
-- to that account, waits for Meet to redirect to the new meeting code, closes the
-- tab, and pastes into the app you were in. The first run asks macOS to let
-- Hammerspoon control Google Chrome (Automation); click OK.

local M = {}

local ACCOUNT = "nathaniel.koerschner@superbuilders.school"
local CHROME_PROFILE = "Default" -- the Chrome profile with ACCOUNT signed in
local TIMEOUT = 20 -- seconds

local CODE = "meet%.google%.com/(%l%l%l%-%l%l%l%l%-%l%l%l)"

local function chromeTabs()
	local ok, out = hs.osascript.applescript([[
		if application "Google Chrome" is not running then return ""
		tell application "Google Chrome"
			set out to ""
			repeat with w in windows
				repeat with t in tabs of w
					set out to out & (id of t) & " " & (URL of t) & linefeed
				end repeat
			end repeat
			return out
		end tell]])
	local tabs = {}
	if ok and out then
		for id, url in tostring(out):gmatch("(%d+) ([^\n]*)") do
			tabs[id] = url
		end
	end
	return tabs
end

local function closeChromeTab(id)
	hs.osascript.applescript(string.format([[
		tell application "Google Chrome"
			repeat with w in windows
				repeat with t in tabs of w
					if id of t is %s then
						close t
						return
					end if
				end repeat
			end repeat
		end tell]], id))
end

function M.create()
	if M.poller then
		return
	end
	local app = hs.application.frontmostApplication()
	local win = hs.window.focusedWindow()
	local before = chromeTabs()
	local url = "https://meet.google.com/new?authuser=" .. ACCOUNT
	hs.task.new("/usr/bin/open", nil, {
		"-g", "-na", "Google Chrome", "--args", "--profile-directory=" .. CHROME_PROFILE, url,
	}):start()
	hs.alert.show("Creating Meet…", 1)

	local started = hs.timer.secondsSinceEpoch()
	M.poller = hs.timer.doEvery(0.25, function()
		for id, tabUrl in pairs(chromeTabs()) do
			local code = not before[id] and tabUrl:match(CODE)
			if code then
				M.poller:stop()
				M.poller = nil
				closeChromeTab(id)
				local link = "https://meet.google.com/" .. code
				hs.pasteboard.setContents(link)
				if win then
					win:focus()
				elseif app then
					app:activate()
				end
				hs.timer.doAfter(0.2, function()
					hs.eventtap.keyStroke({ "cmd" }, "v")
				end)
				return
			end
		end
		if hs.timer.secondsSinceEpoch() - started > TIMEOUT then
			M.poller:stop()
			M.poller = nil
			hs.alert.show("Couldn't create a Meet (is Chrome signed in to " .. ACCOUNT .. "?)", 4)
		end
	end)
end

M.hotkey = hs.hotkey.bind({ "ctrl", "shift", "cmd" }, "m", M.create)

return M
