-- Size for otter launcher
local otterSize = { 410, 220 }
if Hostname == "mobile02" then
	otterSize = { 420, 220 }
end
hl.window_rule({
	name = "otter-launcher",
	match = {
		class = "otter",
	},
	float = true,
	animation = "popin 80%",
	size = otterSize,
	opaque = true,
})

-- Dont dim youtube windows
hl.window_rule({
	name = "nodim-youtube",
	match = {
		class = "^(firefox|Firefox)$",
		title = "^(.*YouTube.*)$",
	},
	no_dim = true,
	opaque = true,
})

-- Define windows that float
local standardFloatingWindows = {
	{ class = "xdg-desktop-portal-gtk" },
	{ class = "org.pulseaudio.pavucontrol" },
	{ class = "firefox", title = ".*Save.*" },
}

-- For every window that floats make a rule
for _, window in ipairs(standardFloatingWindows) do
	hl.window_rule({
		name = ("float " .. window.class),
		match = {
			-- both are optional ig
			class = ("^(" .. (window.class or "") .. ")$"),
			title = ("^(" .. (window.title or "") .. ")"),
		},
		float = true,
		animation = "popin 70%",
		size = { 800, 500 },
	})
end

-- Don't dim fullscreen windows
hl.window_rule({
	name = "nodim fullscreen",
	match = {
		fullscreen = true,
	},
	no_dim = true,
	opaque = true,
})

hl.window_rule({
	name = "jelly slide",
	match = {
		class = "^(jf-tui)$",
	},
	animation = "slide top",
})

-- Define gaps for music workspace
hl.workspace_rule({
	workspace = "special:music",
	gaps_out = {
		left = 400,
		right = 400,
		bottom = 400,
	},
	animation = "slidefadevert",
})

-- Something from the example idk
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})

-- Fix some dragging issues with XWayland
hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- Wlogout blur and stuff
hl.layer_rule({
	name = "wlogout blur",
	match = {
		namespace = "logout_dialog",
	},
	blur = true,
})

-- Notifications
hl.layer_rule({
	name = "notification blur",
	match = {
		namespace = "notifications",
	},
	blur = true,
	ignore_alpha = 0,
})

-- Waybar blur
hl.layer_rule({
	name = "waybar blur",
	match = {
		namespace = "waybar",
	},
	blur = true,
	ignore_alpha = 0,
})

hl.layer_rule({
	name = "astal",
	match = {
		namespace = "system-stats",
	},
	blur = false,
	ignore_alpha = 0,
})

hl.layer_rule({
	name = "showkeys",
	match = {
		namespace = "showkeys",
	},
	blur = false,
	no_anim = true,
})
