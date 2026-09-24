-- EarPods button → voice prompt.
-- While a headset mic (EarPods / external mic) is the default input, the
-- play/pause button toggles recording instead of controlling music. On stop,
-- ~/.local/bin/voice-prompt transcribes locally (whisper.cpp) and delivers the
-- text: ~/voice-inbox.md + clipboard, plus a Herdr agent if one is targeted
-- (`voice-prompt target <agent>`).

local FFMPEG = "/opt/homebrew/bin/ffmpeg"
local VOICE_PROMPT = os.getenv("HOME") .. "/.local/bin/voice-prompt"
voicePromptHeadsets = { "EarPods", "External Microphone", "Headset", "Headphone" }

local recorder = nil
local indicator = nil

local function headsetInput()
	local dev = hs.audiodevice.defaultInputDevice()
	local name = dev and dev:name() or ""
	for _, pattern in ipairs(voicePromptHeadsets) do
		if name:find(pattern, 1, true) then
			return name
		end
	end
	return nil
end

local function deliver(path)
	hs.task
		.new(VOICE_PROMPT, function(code, stdout, stderr)
			os.remove(path)
			local msg = (stdout or ""):gsub("%s+$", "")
			if code ~= 0 then
				msg = "voice-prompt failed: " .. (stderr or "")
			end
			print("voice_prompt: " .. msg)
			hs.notify.new({ title = "Voice prompt", informativeText = msg }):send()
		end, { path })
		:start()
end

local function stopRecording()
	if indicator then
		indicator:delete()
		indicator = nil
	end
	hs.sound.getByName("Pop"):play()
	recorder:interrupt() -- SIGINT lets ffmpeg finalize the wav header
end

local function startRecording(device)
	local path = os.tmpname() .. ".wav"
	recorder = hs.task.new(FFMPEG, function(code, _, stderr)
		if code ~= 0 and code ~= 255 then
			print("voice_prompt: ffmpeg exited " .. code .. ": " .. tostring(stderr))
		end
		recorder = nil
		deliver(path)
	end, { "-hide_banner", "-loglevel", "error", "-f", "avfoundation", "-i", ":" .. device, "-t", "300", "-ar", "16000", "-ac", "1", "-y", path })
	recorder:start()
	hs.sound.getByName("Tink"):play()
	indicator = hs.menubar.new()
	indicator:setTitle("🔴 REC")
end

-- Toggle recording (also callable from `hs -c "voicePromptToggle()"`).
function voicePromptToggle(device)
	if recorder then
		stopRecording()
	else
		startRecording(device or hs.audiodevice.defaultInputDevice():name())
	end
end

voicePromptTap = hs.eventtap
	.new({ hs.eventtap.event.types.systemDefined }, function(evt)
		local key = evt:systemKey()
		if key.key ~= "PLAY" then
			return false
		end
		if recorder then
			if not key.down then
				stopRecording()
			end
			return true
		end
		local device = headsetInput()
		if not device then
			return false -- no headset: play/pause behaves normally
		end
		if not key.down then
			startRecording(device)
		end
		return true
	end)
	:start()

-- macOS can disable event taps (timeouts, secure input); keep it alive.
voicePromptWatchdog = hs.timer.doEvery(2, function()
	if not voicePromptTap:isEnabled() then
		voicePromptTap:start()
	end
end)
