local appList = {
	"waybar",
	"dunst",
	"wpaperd -d",
	"wayvnc 0.0.0.0 --output=DP-1",
	"syncthing -home=/home/user01/.config/syncthing -no-browser",
	"gotify-desktop",
	"sleep 10 && curl -X POST -H 'Content-Type: application/json' -d '{'ref':'$(git -C ~/.dotfiles rev-parse HEAD)', 'status':'$(git -C ~/.dotfiles diff --quiet && echo 'clean' || echo 'dirty')'}' https://n8n.voidarc.co.uk/webhook/config-checker",
}

hl.on("hyprland.start", function()
	for _, command in ipairs(appList) do
		hl.exec_cmd(command)
	end
end)
