-- Single AOC Q27P2G5 1440p over HDMI
hl.monitor({
	output = "HDMI-A-2",
	position = "0x0",
	mode = "2560x1440@60",
	scale = "1.2",
})

-- Fallback for anything hotplugged
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1.2" })
