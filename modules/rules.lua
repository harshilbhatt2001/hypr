hl.window_rule({
	name = "otter-launcher",
	match = {
		class = "otter",
	},
	float = true,
	size = { 410, 220 },
	opaque = true,
})

hl.window_rule({
	name = "nodim-youtube",
})

hl.workspace_rule({
	workspace = "special:music",
	gaps_out = {
		left = 400,
		right = 400,
		bottom = 400,
	},
})
