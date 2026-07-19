hl.config({
	input = {
		kb_layout = "gb", -- Goddamn kier starmer
		follow_mouse = 1, -- Moving to a window will focus it

		touchpad = {
			natural_scroll = true, -- Better scrolling
			disable_while_typing = true, -- Sanity
		},

		sensitivity = -0.3, -- DPI is too high ffs
		force_no_accel = false, -- I love mouse acceleration
		tablet = {
			left_handed = true, -- Top 10 disabilities
			output = "current", -- Make the tablet usable
		},
	},
	cursor = {
		inactive_timeout = 2, -- Hide white thing on the screen
		hide_on_key_press = true, -- Hide white thing when typing
		warp_on_change_workspace = 1, -- Make it go to workspaces
		warp_on_toggle_special = 1, -- Go to special workspaces too
		persistent_warps = true, -- Go back to where it was when I warp
	},
})

if Hostname == "mobile02" then
	hl.config({
		input = { -- If on laptop make caps the escape key but make it be capslock when shift caps is pressed
			kb_options = "caps:escape_shifted_capslock",
		},
	})
elseif Hostname == "HACKSTATION" then
	hl.device({
		name = "weylus-stylus",
		left_handed = false,
		output = "DP-1"
	})
	hl.device({
		name = "weylus-touch",
		output = "DP-1"
	})
end
