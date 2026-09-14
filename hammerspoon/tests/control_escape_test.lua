-- Run from the repository root: lua hammerspoon/tests/control_escape_test.lua
-- Load the real Control/Escape section with a fake Hammerspoon runtime.
local file = assert(io.open("hammerspoon/dot-hammerspoon/init.lua"))
local source = file:read("*a")
file:close()
source = assert(source:match("(%-%- Inspired by https://github.com/jasoncodes/.-)\nhs.hotkey.bind"))

local function setup()
	local s = { tasks = {}, timers = {}, app = "Ghostty", now = 1e9, escapes = 0 }
	local env = setmetatable({}, { __index = _G })
	local function timer(delay, callback)
		local t = { delay = delay, callback = callback, stopped = false }
		function t:stop() self.stopped = true end
		s.timers[#s.timers + 1] = t
		return t
	end
	env.hs = {
		application = { frontmostApplication = function() return { name = function() return s.app end } end },
		timer = { doAfter = timer, doEvery = timer, absoluteTime = function() return s.now end },
		eventtap = {
			event = { types = { flagsChanged = 1, keyDown = 2 } },
			isSecureInputEnabled = function() return s.secure or false end,
			keyStroke = function() s.escapes = s.escapes + 1 end,
			new = function(_, callback)
				local tap = { callback = callback, enabled = false }
				function tap:start() self.enabled = true; return self end
				function tap:isEnabled() return self.enabled end
				return tap
			end,
		},
		task = { new = function(path, callback, stream, args)
			if s.new_fail then return nil end
			local task = { path = path, args = args, callback = callback, stream = stream }
			function task:start()
				if s.start_fail then return false end
				self.running = true
				return self
			end
			function task:isRunning() return self.running end
			function task:terminate() self.terminated = true; self.running = false end
			function task:finish(stdout, code, late)
				self.running = false
				self.callback(code or 0, stdout or "", "")
				if late then self.stream(nil, late, "") end
			end
			s.tasks[#s.tasks + 1] = task
			return task
		end },
	}
	assert(load(source, "control_escape", "t", env))()
	s.env = env
	function s:poll() self.env.tmux_agent_pane_timer.callback() end
	function s:event(kind, flags)
		assert(self.env.control_escape_tap.callback({
			getType = function() return kind end,
			getFlags = function() return flags or {} end,
		}) == false, "physical events must not be swallowed")
	end
	function s:tap() self:event(1, { ctrl = true }); self:event(1, {}) end
	function s:snapshot(panes, processes, late)
		self.tasks[#self.tasks]:finish(panes)
		self:poll()
		assert(self.tasks[#self.tasks].path == "/bin/ps")
		self.tasks[#self.tasks]:finish(processes, 0, late)
		self:poll()
	end
	return s
end

local tests = {
	["unknown terminal state suppresses Escape"] = function()
		local s = setup(); s:tap(); assert(s.escapes == 0)
	end,
	["shell tap works, Ctrl-b and multi-modifier chords never inject Escape"] = function()
		local s = setup(); s:snapshot("1 1 1 10 zsh\n", "10 1 /bin/zsh\n")
		s:tap(); assert(s.escapes == 1)
		s:event(1, { ctrl = true }); s:event(2, { ctrl = true }); s:event(1, {})
		assert(s.escapes == 1)
		s:event(1, { ctrl = true, cmd = true }); s:event(1, { ctrl = true }); s:event(1, {})
		assert(s.escapes == 1)
	end,
	["agent suppresses Escape; editor descendant restores it"] = function()
		local s = setup(); s:snapshot("1 1 1 10 node\n", "10 1 /bin/zsh\n20 10 /bin/node\n")
		s:tap(); assert(s.escapes == 0)
		s:poll(); s:snapshot("1 1 1 10 node\n", "10 1 /bin/zsh\n20 10 /bin/node\n30 20 /bin/nvim\n")
		s:tap(); assert(s.escapes == 1)
	end,
	["large output and delayed stream chunks preserve byte order"] = function()
		local s = setup()
		-- Background-read bytes precede the termination callback's remainder,
		-- even when their stream callback is delivered after termination.
		s.tasks[1]:finish("de\n", 0, "1 1 1 10 no"); s:poll()
		local ps = s.tasks[2]
		assert(ps.stream(ps, string.rep("99 1 /bin/irrelevant\n", 10000), "ignored stderr"))
		ps:finish("10 1 /bin/zsh\n20 10 /bin/node\n")
		s:poll(); s:tap(); assert(s.escapes == 0)
		s:poll(); s.tasks[#s.tasks]:finish("1 1 1 10 node\n"); s:poll()
		s.tasks[#s.tasks]:finish("vim\n", 0, "10 1 /bin/zsh\n20 10 /bin/node\n30 20 /bin/n")
		s:poll(); s:tap(); assert(s.escapes == 1)
	end,
	["timeout kills direct child and retries; stale callback is ignored"] = function()
		local s = setup(); s.tasks[1]:finish("1 1 1 10 node\n"); s:poll()
		local ps = s.tasks[2]
		s.timers[1].callback(); assert(ps.terminated)
		s:tap(); assert(s.escapes == 0)
		s:poll(); assert(#s.tasks == 3)
		ps:finish("30 10 /bin/nvim\n"); s:poll(); s:tap(); assert(s.escapes == 0)
		s:snapshot("1 1 1 10 zsh\n", "10 1 /bin/zsh\n"); s:tap(); assert(s.escapes == 1)
	end,
	["failed exit, construction and start all permit retry"] = function()
		for _, failure in ipairs({ "exit", "new_fail", "start_fail" }) do
			local s = setup(); s.tasks[1]:finish("1 1 1 10 node\n")
			if failure == "exit" then
				s:poll(); s.tasks[2]:finish("", 1); s:poll()
			else
				s[failure] = true; s:poll(); s[failure] = false
			end
			s:tap(); assert(s.escapes == 0)
			s:poll(); s:snapshot("1 1 1 10 zsh\n", "10 1 /bin/zsh\n")
			s:tap(); assert(s.escapes == 1)
		end
	end,
	["stale result suppresses Escape but other apps still receive it"] = function()
		local s = setup(); s:snapshot("1 1 1 10 zsh\n", "10 1 /bin/zsh\n")
		s.now = s.now + 3e9; s:tap(); assert(s.escapes == 0)
		s.app = "Notes"; s:tap(); assert(s.escapes == 1)
	end,
	["disabled tap and Secure Input clear incomplete gestures"] = function()
		for _, secure in ipairs({ false, true }) do
			local s = setup(); s.app = "Notes"
			s:event(1, { ctrl = true })
			s.env.control_escape_tap.enabled = false; s.secure = secure
			s.env.control_escape_watchdog.callback()
			assert(s.env.control_escape_tap.enabled == not secure)
			s.secure = false; s.env.control_escape_watchdog.callback()
			s:event(1, {}); assert(s.escapes == 0)
			s:tap(); assert(s.escapes == 1)
		end
	end,
	["editor in another attached session does not override an agent"] = function()
		local s = setup(); s:snapshot("1 1 1 9 nvim\n1 1 1 10 node\n", "10 1 /bin/node\n")
		s:tap(); assert(s.escapes == 0)
	end,
}
local count = 0
for name, test in pairs(tests) do
	test(); count = count + 1; print("PASS " .. name)
end
print(count .. " tests passed")
