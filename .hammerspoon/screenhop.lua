-- designed to hop screens and activate the window under the mouse
local function focus_other_screen() -- focuses the other screen 
   local screen = hs.mouse.getCurrentScreen()
   local nextScreen = screen:next()
   local rect = nextScreen:fullFrame()
   local center = hs.geometry.rectMidPoint(rect)
   hs.mouse.setAbsolutePosition(center)
end 

function get_window_under_mouse() -- from https://gist.github.com/kizzx2/e542fa74b80b7563045a 
   local my_pos = hs.geometry.new(hs.mouse.getAbsolutePosition())
   local my_screen = hs.mouse.getCurrentScreen()
   return hs.fnutils.find(hs.window.orderedWindows(), function(w)
                 return my_screen == w:screen() and my_pos:inside(w:frame())
   end)
end

function activate_other_screen()
   focus_other_screen() 
   local win = get_window_under_mouse() 
   -- now activate that window 
   win:focus() 
end 

hs.hotkey.bind({"cmd"}, "1", function() -- does the keybinding
      activate_other_screen()
end)


-- Move window to next screen

hs.hotkey.bind({"cmd", "alt"}, '1', function()
  -- get the focused window
  local win = hs.window.focusedWindow()
  -- get the screen where the focused window is displayed, a.k.a. current screen
  local screen = win:screen()
  -- compute the unitRect of the focused window relative to the current screen
  -- and move the window to the next screen setting the same unitRect 
  win:move(win:frame():toUnitRect(screen:frame()), screen:next(), true, 0)
end)