-- WorkSmart Monitor
-- Shows a large on-screen warning if WorkSmart is not running.

local monitor = {}

local CHECK_INTERVAL_SECONDS = 30
local NOTIFICATION_REPEAT_SECONDS = 300
local WORKSMART_APP_PATH = "/Applications/WorkSmart.app"
local WORKSMART_PROCESS_NAME = "worksmart"

local timer = nil
local canvas = nil
local checkInFlight = false
local lastNotifyAt = 0
local wasRunning = nil

local function showBigWarning()
	if canvas then
		return
	end

	local screen = hs.screen.mainScreen()
	local frame = screen and screen:fullFrame() or { x = 0, y = 0, w = 1440, h = 900 }
	local width = math.min(920, frame.w - 80)
	local height = 260
	local x = frame.x + (frame.w - width) / 2
	local y = frame.y + math.max(80, (frame.h - height) * 0.22)

	canvas = hs.canvas.new({ x = x, y = y, w = width, h = height })
	canvas:level(hs.canvas.windowLevels.overlay)
	canvas:behavior({ hs.canvas.windowBehaviors.canJoinAllSpaces, hs.canvas.windowBehaviors.stationary })
	canvas:appendElements({
		{
			type = "rectangle",
			action = "fill",
			fillColor = { red = 0.85, green = 0.05, blue = 0.05, alpha = 0.94 },
			roundedRectRadii = { xRadius = 28, yRadius = 28 },
		},
		{
			type = "rectangle",
			action = "stroke",
			strokeColor = { white = 1, alpha = 0.95 },
			strokeWidth = 6,
			roundedRectRadii = { xRadius = 28, yRadius = 28 },
		},
		{
			type = "text",
			text = "⚠️ WORKSMART IS NOT RUNNING",
			textColor = { white = 1, alpha = 1 },
			textSize = 44,
			textAlignment = "center",
			frame = { x = 30, y = 48, w = width - 60, h = 64 },
		},
		{
			type = "text",
			text = "Activity is not being tracked. Start WorkSmart now.",
			textColor = { white = 1, alpha = 1 },
			textSize = 26,
			textAlignment = "center",
			frame = { x = 40, y = 128, w = width - 80, h = 42 },
		},
		{
			type = "text",
			text = "This warning will disappear automatically once WorkSmart is running.",
			textColor = { white = 1, alpha = 0.9 },
			textSize = 18,
			textAlignment = "center",
			frame = { x = 40, y = 184, w = width - 80, h = 30 },
		},
	})
	canvas:show()
end

local function hideBigWarning()
	if canvas then
		canvas:delete()
		canvas = nil
	end
end

local function notifyNotRunning()
	local now = os.time()
	if now - lastNotifyAt < NOTIFICATION_REPEAT_SECONDS then
		return
	end
	lastNotifyAt = now

	hs.notify.new(function()
		hs.execute('/usr/bin/open "' .. WORKSMART_APP_PATH .. '"')
	end, {
		title = "WorkSmart is not running",
		informativeText = "Activity is not being tracked. Click to open WorkSmart.",
		soundName = "Sosumi",
		withdrawAfter = 0,
	}):send()
end

local function setRunning(isRunning)
	if isRunning then
		hideBigWarning()
		if wasRunning == false then
			hs.notify.show("WorkSmart monitor", "WorkSmart is running", "Tracking appears to be back on.")
		end
	else
		showBigWarning()
		notifyNotRunning()
	end
	wasRunning = isRunning
end

local function checkNow()
	if checkInFlight then
		return
	end
	checkInFlight = true
	hs.task.new("/usr/bin/pgrep", function(exitCode)
		checkInFlight = false
		setRunning(exitCode == 0)
	end, { "-x", WORKSMART_PROCESS_NAME }):start()
end

function monitor.start()
	if timer then
		timer:stop()
	end
	checkNow()
	timer = hs.timer.doEvery(CHECK_INTERVAL_SECONDS, checkNow)
	print("WorkSmart monitor started")
end

function monitor.stop()
	if timer then
		timer:stop()
		timer = nil
	end
	hideBigWarning()
	print("WorkSmart monitor stopped")
end

function monitor.check()
	checkNow()
end

monitor.start()
_G.worksmart_monitor = monitor

return monitor
