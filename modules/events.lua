local appList = {
	"wpaperd -d",
	"quickshell",
	"way-edges",
	"hyprpolkitagent",
}

-- For everything in the applist run it on startup
hl.on("hyprland.start", function()
	for _, command in ipairs(appList) do
		hl.exec_cmd(command)
	end
end)
