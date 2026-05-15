local appList = {
	"waybar",
	"dunst",
	"wpaperd -d",
	"syncthing -home=/home/user01/.config/syncthing -no-browser",
	"gotify-desktop",
	'sleep 5 && curl -X POST -H "Content-Type: application/json" -d "{\\"ref\\":\\"$(git -C ~/.dotfiles rev-parse HEAD)\\", \\"status\\":\\"$(git -C ~/.dotfiles diff --quiet && echo "clean" || echo "dirty")\\"}" https://n8n.voidarc.co.uk/webhook/config-checker',
}

local localAppList
if Hostname == "HACKSTATION" then
	-- If on desktop do desktop things
	localAppList = {
		"wayvnc 0.0.0.0 --output=DP-1",
	}
elseif Hostname == "mobile02" then
	-- If on laptop, do laptop things
	localAppList = {
		"way-edges",
	}
end

for _, command in ipairs(localAppList) do
	table.insert(appList, command)
end

-- For everything in the applist run it on startup
hl.on("hyprland.start", function()
	for _, command in ipairs(appList) do
		hl.exec_cmd(command)
	end
end)
