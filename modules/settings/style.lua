local ctp = require("modules.mocha")
hl.config({
	general = {
		gaps_in = 3,
		resize_on_border = true,
		gaps_out = { top = 5, right = 6, bottom = 6, left = 6 },
		border_size = 3,
		layout = "scrolling",
		col = {
			active_border = {
				colors = { "rgba(" .. ctp.mauve.hex:sub(2) .. "cc)", "rgba(" .. ctp.red.hex:sub(2) .. "cc)" },
				angle = 45,
			},
			inactive_border = {
				colors = { "rgba(" .. ctp.surface1.hex:sub(2) .. "cc)", "rgba(" .. ctp.lavender.hex:sub(2) .. "cc)" },
				angle = 45,
			},
		},
	},
	decoration = {
		rounding = 10,
		rounding_power = 2,

		-- Change transparency of focused and unfocused windows
		active_opacity = 1.0,
		inactive_opacity = 0.8,
		dim_inactive = true,
		dim_strength = 0.2,

		blur = {
			enabled = true,
			size = 2,
			passes = 3,
			vibrancy = 0.5,
		},
	},
})
