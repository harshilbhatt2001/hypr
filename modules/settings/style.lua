-- Import catppuccin colors
local ctp = require("modules.mocha")
hl.config({

	-- gaps and colors
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

	-- Scrolling layout settings
	scrolling = {
		column_width = 0.8,
		follow_min_visible = 0.1,
		focus_fit_method = 0,
		wrap_focus = false,
		wrap_swapcol = false,
	},

	-- Window appearence
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

	-- Remove irritants
	ecosystem = {
		no_update_news = true,
		no_donation_nag = true,
	},
})

hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "20")
