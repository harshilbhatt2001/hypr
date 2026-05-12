hl.config({
	input = {
		kb_layout = "gb",
		follow_mouse = 1,

		touchpad = {
			natural_scroll = true,
			disable_while_typing = true,
		},

		sensitivity = -0.3,
		force_no_accel = false,
		tablet = {
			left_handed = true,
			output = "current",
		},
	},
	cursor = {
		inactive_timeout = 2,
		warp_on_change_workspace = 1,
		hide_on_key_press = true,
		warp_on_toggle_special = 1,
	},
})
