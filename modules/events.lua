local appList = {
	"waybar",
	"dunst",
	"wpaperd -d",
	"wayvnc 0.0.0.0 --output=DP-1",
	"syncthing -home=/home/user01/.config/syncthing -no-browser",
	"gotify-desktop",
	"sleep 10 && curl -X POST -H 'Content-Type: application/json' -d '{'ref':'$(git -C ~/.dotfiles rev-parse HEAD)', 'status':'$(git -C ~/.dotfiles diff --quiet && echo 'clean' || echo 'dirty')'}' https://n8n.voidarc.co.uk/webhook/config-checker",
}

local localAppList
if Hostname == "HACKSTATION" then
	-- If on desktop do all the decoration nonsense
	localAppList = {
		"kitten panel --edge=background -o background_opacity=0 --output-name HDMI-A-1 sh -c 'cmatrix -b -C magenta -a -u 10'",
		"kitten panel --edge=background -o background_opacity=0 --output-name DP-2 sh -c 'cava'",
	}
elseif Hostname == "mobile02" then
	-- If on laptop, launch way-edges
	localAppList = {
		"way-edges",
	}
end

table.insert(appList, localAppList)

-- For everything in the applist run it on startup
hl.on("hyprland.start", function()
	for _, command in ipairs(appList) do
		hl.exec_cmd(command)
	end
end)
