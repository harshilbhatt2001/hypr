-- Single AOC Q27P2G5 1440p over DisplayPort, native (unscaled) at its 75Hz mode
hl.monitor({
	output = "DP-1",
	position = "0x0",
	mode = "2560x1440@74.97",
	scale = "1",
})

-- Fallback for anything hotplugged
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })
