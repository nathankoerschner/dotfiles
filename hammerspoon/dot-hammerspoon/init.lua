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

winmanScreenProfiles = {
	ultrawide = {
		screenNamePattern = "^MPG 491C OLED$",
		minWidth = 3400,
		minAspectRatio = 2.8,
		layouts = {
			centered = { x = 0.2, y = 0, w = 0.6, h = 1 },
			leftFocus = { x = 0, y = 0, w = 0.2, h = 1 },
			rightFocus = { x = 0.8, y = 0, w = 0.2, h = 1 },
		},
	},
}
require("winman")

-- ─── Ultrawide brightness override ──────────────────────────────────────────
-- The MPG 491C OLED ignores DDC brightness while HDR is enabled. With HDR off,
-- push SDR luminance to max whenever the monitor is connected.
local M1DDC = "/opt/homebrew/bin/m1ddc"
local ULTRAWIDE_NAME = "MPG 491C OLED"

local function ultrawideDisplayId()
	local out = hs.execute(M1DDC .. " display list")
	if not out then
		return nil
	end
	for line in out:gmatch("[^\n]+") do
		local id, name = line:match("^%[(%d+)%]%s+(.-)%s+%(")
		if id and name == ULTRAWIDE_NAME then
			return id
		end
	end
	return nil
end

local function setUltrawideBrightness()
	local id = ultrawideDisplayId()
	if id then
		hs.execute(string.format("%s display %s set luminance 100", M1DDC, id))
	end
end

-- Run once on load (covers Hammerspoon reload while monitor is already plugged in)
hs.timer.doAfter(1, setUltrawideBrightness)

-- Re-apply whenever displays change (plug/unplug, wake from sleep)
local lastUltrawidePresent = false
ultrawideWatcher = hs.screen.watcher.new(function()
	local present = false
	for _, s in ipairs(hs.screen.allScreens()) do
		if s:name() == ULTRAWIDE_NAME then
			present = true
			break
		end
	end
	if present and not lastUltrawidePresent then
		hs.timer.doAfter(2, setUltrawideBrightness)
	end
	lastUltrawidePresent = present
end)
ultrawideWatcher:start()
for _, s in ipairs(hs.screen.allScreens()) do
	if s:name() == ULTRAWIDE_NAME then
		lastUltrawidePresent = true
		break
	end
end
-- ────────────────────────────────────────────────────────────────────────────

local module = {}
local appList = {
	["n"] = "Notes",
	["l"] = "Calendar",
	["c"] = "Google Chat",
	["f"] = "Google Chrome",
	["j"] = "cmux",
	["s"] = "Slack",
	["w"] = "WorkFlowy",
	["d"] = "Discord",
	["e"] = "Linear",
	["p"] = "Spotify",
	["r"] = "Reminders",
	["1"] = "1Password",
	["i"] = "Finder",
	["o"] = "Obsidian",
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

-- Monkeytype launcher with custom window size
hs.hotkey.bind({ "ctrl", "cmd" }, "t", function()
	-- Open Monkeytype in a new Chrome window
	local task = hs.task.new(
		"/usr/bin/open",
		nil,
		{ "-na", "Google Chrome", "--args", "--new-window", "https://monkeytype.com/" }
	)
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

-- Books launcher with large custom window size
hs.hotkey.bind({ "ctrl", "cmd" }, "b", function()
	hs.application.launchOrFocus("Books")

	-- Wait for the app window to appear, then resize and center it
	hs.timer.doAfter(0.5, function()
		local books = hs.application.find("Books")
		if books then
			local win = books:focusedWindow() or books:mainWindow()
			if win then
				local screen = win:screen()
				local screenFrame = screen:frame()

				-- Calculate 75% width, 85% height, centered
				local newWidth = screenFrame.w * 0.75
				local newHeight = screenFrame.h * 0.85
				local newX = screenFrame.x + (screenFrame.w - newWidth) / 2
				local newY = screenFrame.y + (screenFrame.h - newHeight) / 2

				win:setFrame(hs.geometry.rect(newX, newY, newWidth, newHeight))
			end
		end
	end)
end)

-- Quick reminder creation
local quickReminderWebview = nil
local reminderListCache = { "Reminders" }
local reminderListRefreshInFlight = false

local function appleScriptString(value)
	value = tostring(value or "")
	value = value:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\r\n", "\n"):gsub("\r", "\n")
	return '"' .. value:gsub("\n", '" & return & "') .. '"'
end

local function htmlEscape(value)
	value = tostring(value or "")
	return value:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;")
end

local function parseReminderLists(text)
	local lists = {}
	for listName in tostring(text or ""):gmatch("[^\r\n]+") do
		if listName ~= "" then
			table.insert(lists, listName)
		end
	end
	return #lists > 0 and lists or { "Reminders" }
end

local function refreshReminderLists()
	if reminderListRefreshInFlight then
		return
	end
	reminderListRefreshInFlight = true
	hs.task.new("/usr/bin/osascript", function(exitCode, stdOut, stdErr)
		reminderListRefreshInFlight = false
		if exitCode == 0 then
			reminderListCache = parseReminderLists(stdOut)
		elseif stdErr and stdErr ~= "" then
			print("Reminder list refresh error: " .. stdErr)
		end
	end, {
		"-e",
		[[tell application "Reminders"
	set listNames to name of every list
	set AppleScript's text item delimiters to linefeed
	set listText to listNames as text
	set AppleScript's text item delimiters to ""
	return listText
end tell]],
	}):start()
end

local function getReminderLists()
	return reminderListCache
end

local function appleScriptDateSetter(dateString)
	local year, month, day = tostring(dateString or ""):match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
	if not year then
		return ""
	end
	local monthNames = {
		"January",
		"February",
		"March",
		"April",
		"May",
		"June",
		"July",
		"August",
		"September",
		"October",
		"November",
		"December",
	}
	local monthName = monthNames[tonumber(month)]
	if not monthName then
		return ""
	end
	return string.format(
		[[
		set dueDateValue to current date
		set year of dueDateValue to %d
		set month of dueDateValue to %s
		set day of dueDateValue to %d
		set time of dueDateValue to 0
		set allday due date of newReminder to dueDateValue]],
		year,
		monthName,
		day
	)
end

local function createReminder(title, notes, listName, dueDate)
	local properties = "name:" .. appleScriptString(title)
	if notes and notes ~= "" then
		properties = properties .. ", body:" .. appleScriptString(notes)
	end

	local script = string.format(
		[[
tell application "Reminders"
	tell list %s
		set newReminder to make new reminder with properties {%s}%s
	end tell
end tell
]],
		appleScriptString(listName or "Reminders"),
		properties,
		appleScriptDateSetter(dueDate)
	)

	-- Run AppleScript asynchronously so the UI can close immediately.
	hs.task
		.new("/usr/bin/osascript", function(exitCode, _, stdErr)
			if exitCode ~= 0 then
				hs.alert.show("Could not add reminder")
				print("Reminder AppleScript error: " .. tostring(stdErr))
			end
		end, { "-" })
		:setInput(script)
		:start()
end

hs.timer.doAfter(1, refreshReminderLists)

local function showQuickReminderDialog()
	if quickReminderWebview then
		quickReminderWebview:delete()
		quickReminderWebview = nil
	end

	local screenFrame = hs.screen.mainScreen():frame()
	local width, height = 560, 510
	local rect = hs.geometry.rect(
		screenFrame.x + (screenFrame.w - width) / 2,
		screenFrame.y + (screenFrame.h - height) / 2,
		width,
		height
	)

	local controller = hs.webview.usercontent.new("reminder")
	controller:setCallback(function(message)
		if not message or not message.body then
			return
		end

		local body = message.body
		if body.action == "resize" then
			local desiredHeight = tonumber(body.height)
			if desiredHeight and quickReminderWebview then
				local frame = quickReminderWebview:frame()
				local maxHeight = hs.screen.mainScreen():frame().h - 80
				local newHeight = math.min(maxHeight, math.max(360, math.ceil(desiredHeight + 44)))
				if math.abs(frame.h - newHeight) > 3 then
					frame.y = frame.y + ((frame.h - newHeight) / 2)
					frame.h = newHeight
					quickReminderWebview:frame(frame)
				end
			end
			return
		end

		if body.action == "cancel" then
			if quickReminderWebview then
				quickReminderWebview:delete()
				quickReminderWebview = nil
			end
			return
		end

		if body.action == "add" then
			local title = body.title or ""
			local notes = body.notes or ""
			local listName = body.listName or "Reminders"
			local dueDate = body.dueDate or ""
			if title:gsub("%s+", "") == "" then
				hs.alert.show("Reminder title is required")
				return
			end

			-- Close the window first so it feels as snappy as Escape, then
			-- create the reminder in the background.
			if quickReminderWebview then
				quickReminderWebview:delete()
				quickReminderWebview = nil
			end
			createReminder(title, notes, listName, dueDate)
		end
	end)

	local listOptions = ""
	for _, listName in ipairs(getReminderLists()) do
		local selected = listName == "Reminders" and " selected" or ""
		listOptions = listOptions .. string.format(
			'<option value="%s"%s>%s</option>',
			htmlEscape(listName),
			selected,
			htmlEscape(listName)
		)
	end

	local html = [[
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<style>
	:root { color-scheme: light dark; }
	* { box-sizing: border-box; }
	body {
		margin: 0;
		font: 14px -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
		background: #f5f5f7;
		color: #1d1d1f;
		overflow: hidden;
	}
	.main { padding: 24px; }
	h1 { margin: 0 0 6px; font-size: 22px; font-weight: 650; }
	.subtitle { margin: 0 0 20px; color: #6e6e73; }
	label { display: block; margin: 16px 0 7px; font-weight: 600; }
	input, textarea, select {
		width: 100%;
		border: 1px solid #d2d2d7;
		border-radius: 10px;
		padding: 10px 12px;
		font: inherit;
		background: white;
		color: inherit;
		outline: none;
	}
	input:focus, textarea:focus, select:focus {
		border-color: #007aff;
		box-shadow: 0 0 0 3px rgba(0, 122, 255, 0.18);
	}
	.row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
	select { height: 41px; }
	textarea { min-height: 150px; resize: none; line-height: 1.35; }
	.footer {
		display: flex;
		justify-content: flex-end;
		gap: 10px;
		margin-top: 18px;
	}
	button {
		border: 0;
		border-radius: 9px;
		padding: 8px 16px;
		font: inherit;
		font-weight: 600;
		cursor: pointer;
	}
	.secondary { background: #e8e8ed; color: #1d1d1f; }
	.primary { background: #007aff; color: white; }
	.muted { color: #86868b; font-size: 12px; font-weight: 500; }
	@media (prefers-color-scheme: dark) {
		body { background: #1c1c1e; color: #f5f5f7; }
		.subtitle, .muted { color: #a1a1a6; }
		input, textarea, select { background: #2c2c2e; border-color: #48484a; }
		.secondary { background: #3a3a3c; color: #f5f5f7; }
	}
</style>
</head>
<body>
	<div class="main">
		<h1>New Reminder</h1>

		<label for="title">Reminder</label>
		<input id="title" autocomplete="off" placeholder="What do you want to remember?" autofocus>

		<label for="notes">Notes</label>
		<textarea id="notes" placeholder="Optional details…"></textarea>

		<div class="row">
			<div>
				<label for="list">List</label>
				<select id="list">__LIST_OPTIONS__</select>
			</div>
			<div>
				<label for="dueDate">Date</label>
				<input id="dueDate" type="date">
			</div>
		</div>

		<div class="footer">
			<button class="secondary" id="cancel">Cancel</button>
			<button class="primary" id="add">Add Reminder</button>
		</div>
	</div>

<script>
	const title = document.getElementById('title');
	const list = document.getElementById('list');
	const dueDate = document.getElementById('dueDate');
	const notes = document.getElementById('notes');

	function post(message) {
		webkit.messageHandlers.reminder.postMessage(message);
	}

	function addReminder() {
		post({ action: 'add', title: title.value, listName: list.value, dueDate: dueDate.value, notes: notes.value });
	}

	function resizeToContent() {
		const main = document.querySelector('.main');
		post({ action: 'resize', height: Math.ceil(main.getBoundingClientRect().height) });
	}

	document.getElementById('add').addEventListener('click', addReminder);
	document.getElementById('cancel').addEventListener('click', () => post({ action: 'cancel' }));
	document.addEventListener('keydown', (event) => {
		if (event.key === 'Escape') {
			event.preventDefault();
			event.stopPropagation();
			post({ action: 'cancel' });
		}
		if ((event.metaKey || event.ctrlKey) && event.key === 'Enter') {
			event.preventDefault();
			event.stopPropagation();
			addReminder();
		}
	});
	window.addEventListener('load', resizeToContent);
	setTimeout(resizeToContent, 50);
	setTimeout(() => title.focus(), 50);
</script>
</body>
</html>
]]
	html = html:gsub("__LIST_OPTIONS__", function()
		return listOptions
	end)

	quickReminderWebview = hs.webview.new(rect, { developerExtrasEnabled = true }, controller)
	quickReminderWebview:windowStyle({ "titled", "closable", "utility" })
	quickReminderWebview:allowTextEntry(true)
	quickReminderWebview:closeOnEscape(true)
	quickReminderWebview:deleteOnClose(true)
	quickReminderWebview:shadow(true)
	quickReminderWebview:html(html)
	quickReminderWebview:show()
	quickReminderWebview:hswindow():focus()
end

hs.hotkey.bind({ "cmd", "shift" }, "space", showQuickReminderDialog)

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

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "h", function()
	hs.reload()
end)
