local appList = {
	"wpaperd -d",
	"quickshell",
}

-- For everything in the applist run it on startup
hl.on("hyprland.start", function()
	for _, command in ipairs(appList) do
		hl.exec_cmd(command)
	end
end)
