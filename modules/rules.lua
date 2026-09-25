-- Size for otter launcher
local otterSize = { 410, 220 }
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
		class = "^(zen)$",
		title = "^(.*YouTube.*)$",
	},
	no_dim = true,
	opaque = true,
})

-- Define windows that float
local standardFloatingWindows = {
	{ class = "xdg-desktop-portal-gtk" },
	{ class = "org.pulseaudio.pavucontrol" },
	{ class = "zen", title = ".*Save.*" },
}

-- SUPER + \ keybinding overview: centered float. Sizes are in logical px,
-- which at native scale equals physical px on the 2560x1440 monitor; center
-- is applied after size and respects reserved areas (the bar).
hl.window_rule({
	name = "binds-overview",
	match = {
		class = "hypr-binds",
	},
	float = true,
	size = { 1200, 900 },
	center = true,
	animation = "popin 80%",
	opaque = true,
})

-- SUPER + SHIFT + RETURN scratchpad terminal: lives on special:term so the
-- same instance follows across workspaces; centered float
hl.window_rule({
	name = "scratchpad-terminal",
	match = {
		class = "scratchterm",
	},
	workspace = "special:term",
	float = true,
	size = { 1920, 1080 },
	center = true,
	animation = "popin 80%",
	opaque = true,
})

-- SUPER + S YouTube Music scratchpad (shared keymap action `music`): lives on
-- special:music so the toggle only hides it and playback continues; centered
-- float. Electron reports the X11 class (title-cased) under XWayland and the
-- kebab-case one on native Wayland, so match both.
hl.window_rule({
	name = "music-scratchpad",
	match = {
		class = "^(YouTube Music Desktop App|youtube-music-desktop-app)$",
	},
	workspace = "special:music",
	float = true,
	size = { 1600, 900 },
	center = true,
	animation = "popin 80%",
	opaque = true,
})

-- Opencode overlay: full-width sheet dropping down from the very
-- top edge of the monitor, so the bar draws over its top strip -- deliberate,
-- the sheet is meant to run edge to edge. Same idiom as the scratchpad
-- terminal above: it lives on its own special workspace so the toggle merely
-- hides it (see modules/binds.lua) and the opencode session stays alive.
-- Class and height knobs are in modules/opencode-overlay.lua.
local overlay = require("modules.opencode-overlay")
local overlayMatch = { class = overlay.class }

-- Zero decoration: no border (so no gradient focus ring either), no rounding,
-- no shadow, and no dim/opacity change when it loses focus -- a bare flush
-- panel. kitty's own padding is dropped in the spawn command (modules/binds.lua).
hl.window_rule({
	name = "opencode-overlay",
	match = overlayMatch,
	workspace = "special:" .. overlay.workspace,
	float = true,
	animation = "slide top",
	opaque = true,
	border_size = 0,
	rounding = 0,
	no_shadow = true,
	no_dim = true,
})

-- Anchored to the monitor's top-left corner, ignoring the area the bar reserves.
-- `move` has to be a rule of its own: paired with `size` in the same
-- hl.window_rule call the two clobber each other and only move survives.
hl.window_rule({
	name = "opencode-overlay-position",
	match = overlayMatch,
	move = { 0, 0 },
})

-- Rule sizes are literal logical pixels here (percentages are not accepted),
-- so height_pct is resolved against the monitor. On a cold start the config is
-- parsed before any output exists and hl.get_monitors() can come back empty,
-- hence the rebuild on monitor events -- monitors always appear before the
-- first window, so the overlay never opens with a stale size.
local overlaySizeRule
local function apply_overlay_size()
	local monitors = hl.get_monitors()
	local monitor = monitors[1]
	for _, candidate in ipairs(monitors) do
		if candidate.focused then
			monitor = candidate
		end
	end
	if not monitor then
		return
	end

	local scale = tonumber(monitor.scale) or 1
	local width = math.floor(monitor.width / scale + 0.5)
	local height = math.floor(monitor.height / scale * overlay.height_pct / 100 + 0.5)

	-- Retire the previous one so repeated monitor changes don't stack rules up
	if overlaySizeRule then
		overlaySizeRule:set_enabled(false)
	end
	overlaySizeRule = hl.window_rule({
		name = "opencode-overlay-size",
		match = overlayMatch,
		size = { width, height },
	})
end

apply_overlay_size()
hl.on("monitor.added", apply_overlay_size)
hl.on("monitor.layout_changed", apply_overlay_size)

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

