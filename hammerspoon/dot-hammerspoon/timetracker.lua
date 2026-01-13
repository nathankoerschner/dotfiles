-- Time Tracker Module
-- Prompts every 15 minutes to log activity, creates calendar entries

local timetracker = {}

-- Configuration
local INTERVAL_MINUTES = 15
local IDLE_THRESHOLD_SECONDS = 900 -- 15 minutes

-- State
local promptTimer = nil
local promptOpen = false
local lastPromptTime = nil
local returnedActiveAt = nil  -- timestamp when user returned from being away
local partialStartTime = nil  -- start time for partial period (used in callback)
local wasIdleOnLastPrompt = false  -- track if we skipped due to idle

-- Forward declaration
local scheduleNextPrompt

-- Caffeinate watcher for wake/unlock events
local caffeinateWatcher = hs.caffeinate.watcher.new(function(event)
    if event == hs.caffeinate.watcher.screensDidUnlock or
       event == hs.caffeinate.watcher.systemDidWake then
        returnedActiveAt = os.time()
        promptOpen = false  -- Clear stale prompt state
        print("Time Tracker: User returned at " .. os.date("%H:%M:%S", returnedActiveAt))
        scheduleNextPrompt()  -- Ensure timer is valid after wake
    end
end)
caffeinateWatcher:start()

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
    print("Time Tracker: notification callback triggered")
    promptOpen = false

    local response = notification:response()
    if response and response ~= "" then
        local endTime = lastPromptTime
        local startTime
        if partialStartTime then
            -- Use partial period start time
            startTime = partialStartTime
        else
            -- Full 15-minute block
            startTime = endTime - (INTERVAL_MINUTES * 60)
        end
        createCalendarEntry(response, startTime, endTime)
    end
    -- If dismissed or empty, do nothing (gap in tracking)
end

-- Show the prompt notification
local function showPrompt()
    print("Time Tracker: showPrompt called, promptOpen=" .. tostring(promptOpen))
    if promptOpen then
        print("Time Tracker: prompt already open, skipping")
        return -- Don't stack prompts
    end

    -- Check idle state
    local idleTime = hs.host.idleTime()
    if idleTime >= IDLE_THRESHOLD_SECONDS then
        -- User is idle, skip this prompt (timer callback will reschedule)
        print("Time Tracker: user idle for " .. math.floor(idleTime) .. "s, skipping prompt")
        wasIdleOnLastPrompt = true
        return
    end

    promptOpen = true
    lastPromptTime = os.time()

    -- Determine if this is a partial period (returning from away)
    local promptText = string.format("What did you spend the last %d minutes doing?", INTERVAL_MINUTES)
    partialStartTime = nil  -- Reset for full period by default

    if wasIdleOnLastPrompt or returnedActiveAt then
        -- User returned from being away
        local activeStart = returnedActiveAt
        if not activeStart then
            -- Estimate return time based on current idle time
            activeStart = os.time() - math.floor(idleTime)
        end

        -- Only use partial if return was within this 15-min interval
        local intervalStart = lastPromptTime - (INTERVAL_MINUTES * 60)
        if activeStart > intervalStart then
            local minutesSinceReturn = math.floor((lastPromptTime - activeStart) / 60)
            if minutesSinceReturn > 0 and minutesSinceReturn < INTERVAL_MINUTES then
                promptText = string.format("What did you do for the last %d minute%s?",
                    minutesSinceReturn, minutesSinceReturn == 1 and "" or "s")
                partialStartTime = activeStart
            end
        end

        -- Clear the flags
        wasIdleOnLastPrompt = false
        returnedActiveAt = nil
    end

    local notification = hs.notify.new(notificationCallback, {
        title = "Time Tracker",
        informativeText = promptText,
        hasReplyButton = true,
        withdrawAfter = 0,  -- Don't auto-withdraw
        soundName = "Glass",
    })
    notification:send()
    print("Time Tracker: notification sent - " .. promptText)
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

-- Start the time tracker
function timetracker.start()
    scheduleNextPrompt()
    print("Time Tracker started - next prompt in " .. getNextAlignedTime() .. " seconds")
end

-- Stop the time tracker
function timetracker.stop()
    if promptTimer then
        promptTimer:stop()
        promptTimer = nil
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
