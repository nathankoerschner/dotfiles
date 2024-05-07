-- Table to hold the modifier when left control is pressed
local leftCtrlPressed = false

-- Function to handle left control down event
function leftCtrlDown()
	leftCtrlPressed = true
	-- Send command+option+control modifiers
	hs.notify.new({ title = "Hammerspoon", informativeText = "leftCtrlDown" }):send()
	hs.eventtap.event.newKeyEvent({ "cmd", "alt", "ctrl" }, "", true):post()
end

-- Function to handle left control up event
function leftCtrlUp()
	if leftCtrlPressed then
		leftCtrlPressed = false
		hs.notify.new({ title = "Hammerspoon", informativeText = "leftCtrlUp" }):send()

		-- Release command+option+control modifiers
		hs.eventtap.event.newKeyEvent({ "cmd", "alt", "ctrl" }, "", false):post()
	end
end

-- Create an event tap to listen for keyDown events
local ctrlDown = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
	local keyCode = event:getKeyCode()
	if keyCode == 0x3B then -- 0x3B is the left control key
		leftCtrlDown()
		return true
	end
end)

-- Create an event tap to listen for keyUp events
local ctrlUp = hs.eventtap.new({ hs.eventtap.event.types.keyUp }, function(event)
	local keyCode = event:getKeyCode()
	if keyCode == 0x3B then -- 0x3B is the left control key
		leftCtrlUp()
		return true
	end
end)

-- Start the event taps
ctrlDown()
ctrlUp()
