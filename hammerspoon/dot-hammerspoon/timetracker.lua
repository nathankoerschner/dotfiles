-- Time Tracker Module
-- Prompts every 15 minutes to log activity, creates calendar entries

local timetracker = {}

-- Configuration
local INTERVAL_MINUTES = 15

-- State
local promptTimer = nil
local promptOpen = false
local lastPromptTime = nil
local activeNotification = nil
local wakeWatcher = nil

-- Forward declaration
local scheduleNextPrompt

-- Calculate the next aligned time (next :00, :15, :30, or :45)
local function getNextAlignedTime()
    local now = os.date("*t")
    local currentMinute = now.min
    local nextAligned = math.ceil((currentMinute + 1) / INTERVAL_MINUTES) * INTERVAL_MINUTES

    if nextAligned >= 60 then
        nextAligned = 0
    end

    -- Calculate seconds until next aligned time
    local minutesToWait = nextAligned - currentMinute
    if minutesToWait <= 0 then
        minutesToWait = minutesToWait + 60
    end
    local secondsToWait = (minutesToWait * 60) - now.sec

    return secondsToWait
end

-- Create calendar entry via osascript shell command
local function createCalendarEntry(title, startTimestamp, endTimestamp)
    -- Escape single quotes for shell
    local escapedTitle = title:gsub("'", "'\\''")

    local startDate = os.date("*t", startTimestamp)
    local endDate = os.date("*t", endTimestamp)

    local script = string.format([[
set startDate to current date
set year of startDate to %d
set month of startDate to %d
set day of startDate to %d
set hours of startDate to %d
set minutes of startDate to %d
set seconds of startDate to 0

set endDate to current date
set year of endDate to %d
set month of endDate to %d
set day of endDate to %d
set hours of endDate to %d
set minutes of endDate to %d
set seconds of endDate to 0

tell application "Calendar" to launch
delay 0.3
tell application "Calendar"
    tell calendar "Actual"
        make new event with properties {summary:"%s", start date:startDate, end date:endDate}
    end tell
end tell
]],
    startDate.year, startDate.month, startDate.day, startDate.hour, startDate.min,
    endDate.year, endDate.month, endDate.day, endDate.hour, endDate.min,
    escapedTitle)

    local cmd = "osascript -e '" .. script:gsub("'", "'\\''") .. "'"
    local output, status = hs.execute(cmd)
    if not status then
        hs.notify.show("Time Tracker", "Error", "Failed to create calendar entry")
        print("Calendar error:", output)
    end
end

-- Handle notification callback
local function notificationCallback(notification)
    promptOpen = false
    activeNotification = nil
    local response = notification:response()
    if response and response ~= "" then
        local endTime = lastPromptTime
        local startTime = endTime - (INTERVAL_MINUTES * 60)
        createCalendarEntry(response, startTime, endTime)
    end
end

-- Show the prompt notification
local function showPrompt()
    if promptOpen then
        return -- Don't stack prompts
    end

    promptOpen = true
    lastPromptTime = os.time()

    activeNotification = hs.notify.new(notificationCallback, {
        title = "Time Tracker",
        informativeText = "What did you do in the last 15 minutes?",
        hasReplyButton = true,
        withdrawAfter = 0,
        soundName = "Glass",
    })
    activeNotification:send()
end

-- Schedule the next prompt at aligned time
scheduleNextPrompt = function()
    if promptTimer then
        promptTimer:stop()
    end

    local secondsToWait = getNextAlignedTime()
    local nextTime = os.date("%H:%M:%S", os.time() + secondsToWait)
    print(string.format("Time Tracker: scheduling next prompt in %d seconds (at %s)", secondsToWait, nextTime))

    promptTimer = hs.timer.doAfter(secondsToWait, function()
        print("Time Tracker: timer fired at " .. os.date("%H:%M:%S"))
        local success, err = pcall(showPrompt)
        if not success then
            print("Time Tracker ERROR in showPrompt: " .. tostring(err))
        end
        scheduleNextPrompt()
    end)
end

-- Handle system wake to realign timer
local function handleWakeEvent(event)
    if event == hs.caffeinate.watcher.systemDidWake then
        print("Time Tracker: system woke, rescheduling to next aligned time")
        scheduleNextPrompt()
    end
end

-- Start the time tracker
function timetracker.start()
    -- Start wake watcher to handle sleep/wake alignment
    if wakeWatcher then
        wakeWatcher:stop()
    end
    wakeWatcher = hs.caffeinate.watcher.new(handleWakeEvent)
    wakeWatcher:start()

    scheduleNextPrompt()
    print("Time Tracker started - next prompt in " .. getNextAlignedTime() .. " seconds")
end

-- Stop the time tracker
function timetracker.stop()
    if promptTimer then
        promptTimer:stop()
        promptTimer = nil
    end
    if wakeWatcher then
        wakeWatcher:stop()
        wakeWatcher = nil
    end
    print("Time Tracker stopped")
end

-- Manually trigger prompt (for testing) - does not affect scheduled timer
function timetracker.trigger()
    print("Time Tracker: manual trigger (scheduled timer unaffected)")
    showPrompt()
end

-- Show status of the timer
function timetracker.status()
    local secondsToNext = getNextAlignedTime()
    local nextTime = os.date("%H:%M:%S", os.time() + secondsToNext)
    local timerRunning = promptTimer and promptTimer:running() or false
    print(string.format("Time Tracker status: timer running=%s, next aligned time=%s (%ds), promptOpen=%s",
        tostring(timerRunning), nextTime, secondsToNext, tostring(promptOpen)))
    return timerRunning
end

-- Auto-start on load
timetracker.start()

-- Expose globally for console access
_G.timetracker = timetracker

return timetracker
