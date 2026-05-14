if Hostname == "HACKSTATION" then
	hl.monitor({
		output = "DP-1",
		position = "0x0",
		mode = "1920x1080@60",
		scale = "1",
	})

	hl.monitor({
		output = "DP-2",
		position = "1920x0",
		mode = "1920x1080@60",
		scale = "1",
	})

	hl.monitor({
		output = "HDMI-A-1",
		position = "-1920x0",
		mode = "1920x1080@60",
		scale = "1",
	})

	hl.workspace_rule({ workspace = "1", monitor = "DP-1" })
	hl.workspace_rule({ workspace = "4", monitor = "DP-1" })
	hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1" })
	hl.workspace_rule({ workspace = "3", monitor = "DP-2" })
else
	hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1.2" })
end
