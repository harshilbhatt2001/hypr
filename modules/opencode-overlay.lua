-- Quake-style pull-down overlay for opencode.
--
-- Every knob for the overlay lives here; the two consumers only read it:
--   modules/binds.lua  -- the toggle bind, and the kitty spawn command
--   modules/rules.lua  -- the window rule that shapes and places the overlay
--
-- Edit the numbers below and `hyprctl reload` -- no rebuild needed.
return {
	-- Class kitty is launched with, and the class the window rule matches on
	class = "opencode-overlay",

	-- Special workspace the overlay lives on. Toggling that workspace is what
	-- shows/hides it, so dismissing the overlay never kills the process and the
	-- running opencode session survives.
	workspace = "opencode",

	-- Overlay height, as a percentage of the monitor height. The one knob worth
	-- touching: the overlay is always full width and anchored to the very top
	-- edge of the monitor (0,0), so only its height is configurable.
	height_pct = 45,
}
