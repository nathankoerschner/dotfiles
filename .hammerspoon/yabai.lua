-- cSpell:words koekeishiya yabai fullscreen unfloat hjkl
--
-- ██╗   ██╗ █████╗ ██████╗  █████╗ ██╗
-- ╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗██║
--  ╚████╔╝ ███████║██████╔╝███████║██║
--   ╚██╔╝  ██╔══██║██╔══██╗██╔══██║██║
--    ██║   ██║  ██║██████╔╝██║  ██║██║
--    ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝
--
-- https://github.com/koekeishiya/yabai

local function yabai(commands)
	for _, cmd in ipairs(commands) do
		os.execute("/opt/homebrew/bin/yabai -m " .. cmd)
	end
end

local function cmd(key, commands)
	hs.hotkey.bind({ "cmd" }, key, function()
		yabai(commands)
	end)
end

local function alt(key, commands)
	hs.hotkey.bind({ "alt" }, key, function()
		yabai(commands)
	end)
end



local function altShift(key, commands)
	hs.hotkey.bind({ "alt", "shift" }, key, function()
		yabai(commands)	
	end)
end

local function cmdShift(key, commands)
	hs.hotkey.bind({ "cmd", "shift" }, key, function()
		yabai(commands)
	end)
end



local homeRow = { h = "west", j = "south", k = "north", l = "east" }

for key, direction in pairs(homeRow) do
  cmd(key, { "window --focus " .. direction })
  cmdShift(key, { "window --swap " .. direction })
end

-- alpha
alt("f", { "window --toggle zoom-fullscreen" })
alt("m", { "space --toggle mission-control" })
alt("g", { "space --toggle padding", "space --toggle gap" })
alt("r", { "space --rotate 270" })


altShift("h", { "window --resize left:-50:0", "window --resize right:-50:0" })
altShift("j", { "window --resize bottom:0:50", "window --resize top:0:50" })
altShift("k", { "window --resize top:0:-50", "window --resize bottom:0:-50" })
altShift("l", { "window --resize right:50:0", "window --resize left:50:0" })

-- alt("t", { "window --toggle float", "window --grid 4:4:1:1:2:2" })

alt("'", { "space --layout stack" })
alt(";", { "space --layout bsp" })
alt("tab", { "space --focus recent" })
alt("e", { "window --toggle split" })
altShift("0", { "space --balance" })
