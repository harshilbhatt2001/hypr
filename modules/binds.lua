-- Get window position relative to monitor
-- (single monitor at 0x0, so window x is already monitor-relative)
local function normalise_current_window_pos()
	local active = hl.get_active_window()
	if active then
		return active.at.x
	end
end

-- Notification helper function
local function notif(text, timeout, icon)
	hl.notification.create({
		text = text or "notification",
		timeout = timeout or 2000,
		icon = icon or "ok",
	})
end

-- Class/workspace of the opencode overlay; its window rule is in rules.lua
local overlay = require("modules.opencode-overlay")

-- Set modifier keys
local mainMod = "SUPER + "
local subMod = mainMod
local recordingMode = 0

-- Keybinding overview: every bind below carries a desc; they are collected
-- here and written to a text file on config (re)load. SUPER + \ shows it.
local overviewPath = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/hypr-binds-overview.txt"
local overviewLines = { "Keybindings (SUPER = Windows key)  —  q closes this window" }

local function note(combo, desc)
	table.insert(overviewLines, string.format("  %-26s %s", combo, desc))
end

local function section(title)
	table.insert(overviewLines, "")
	table.insert(overviewLines, title)
end

-- Column focus with monitor fallback (shared by h/l and arrow keys)
local function focus_column_right()
	-- Move before so you can detect if it is the last window
	hl.dispatch(hl.dsp.layout("move +col"))
	if not normalise_current_window_pos() then
		-- Go back a window
		hl.dispatch(hl.dsp.layout("move -col"))
		-- Move to monitor to the right
		hl.dispatch(hl.dsp.focus({ monitor = "right" }))
	end
end

local function focus_column_left()
	local pos = normalise_current_window_pos()
	if pos then
		-- 9 derived from 5 gap plus 3 border (8), so first pixel of window is 9
		if pos == 9 then
			-- If first window, then move to monitor to the left
			hl.dispatch(hl.dsp.focus({ monitor = "left" }))
		else
			-- If not the first window then go to the column to the left
			hl.dispatch(hl.dsp.layout("move -col"))
		end
	end
end

-- Keybinds mirror the niri config (features/niri in the nixos repo):
-- Q close, W browser, F maximize, Shift+F fullscreen, V float,
-- Shift+E quit, numbers for workspaces, U/I workspace down/up.
-- Entries with `header` only mark sections in the overview.
local globalAppBinds = {

	{ header = "Windows" },
	{ key = "q", desc = "close window", dispatch = hl.dsp.window.close() },
	{
		key = "f",
		desc = "maximize window",
		dispatch = hl.dsp.window.fullscreen({ action = "toggle", mode = "maximized" }),
	},
	{ key = "SHIFT + f", desc = "fullscreen window", dispatch = hl.dsp.window.fullscreen({ action = "toggle" }) },
	{ key = "v", desc = "toggle floating", dispatch = hl.dsp.window.float() },
	{ mod = subMod, key = "space", desc = "toggle floating", dispatch = hl.dsp.window.float() },
	{ key = "SHIFT + e", desc = "exit hyprland", dispatch = hl.dsp.exit() },

	{ header = "Apps" },
	-- Browser
	{ key = "w", desc = "browser (zen)", dispatch = "zen" },

	-- Launcher
	{
		key = "d",
		desc = "app launcher (otter)",
		dispatch = function()
			if hl.get_windows({ class = "otter" })[1] ~= nil then
				hl.dispatch(hl.dsp.focus({ window = "class:otter" }))
			else
				hl.exec_cmd("kitty --class otter --title otter-launcher -e sh -c 'sleep 0.05 && otter-launcher'")
			end
		end,
	},

	-- Terminal
	{
		key = "RETURN",
		desc = "terminal (kitty)",
		dispatch = function()
			if recordingMode == 1 then
				hl.exec_cmd("kitty -o font_size=24 -o window_margin_width=20")
			else
				hl.exec_cmd("kitty")
			end
		end,
	},

	-- Scratchpad terminal: one persistent kitty on special:term, toggled
	-- from any workspace (window rule in rules.lua sends it there)
	{
		key = "SHIFT + RETURN",
		desc = "toggle scratchpad terminal",
		dispatch = function()
			if hl.get_windows({ class = "scratchterm" })[1] == nil then
				hl.exec_cmd("kitty --class scratchterm")
			end
			hl.dispatch(hl.dsp.workspace.toggle_special("term"))
		end,
	},

	-- Quake-style opencode overlay: a full-width sheet at the top of the screen.
	-- Toggling only shows/hides its special workspace, so the opencode session
	-- is never killed; the first press spawns it and drops it down.
	-- `-o` overrides the wrapped kitty's padding for this instance only, so the
	-- TUI sits flush in the sheet while normal terminals keep their padding.
	{
		key = "backslash",
		desc = "toggle opencode overlay",
		dispatch = function()
			if hl.get_windows({ class = overlay.class })[1] == nil then
				hl.exec_cmd("kitty -o window_padding_width=0 --class " .. overlay.class .. " -e opencode")
			end
			hl.dispatch(hl.dsp.workspace.toggle_special(overlay.workspace))
		end,
	},

	-- File browser
	{ key = "s", desc = "file browser (nemo)", dispatch = "nemo" },

	-- Power menu
	{ key = "BACKSPACE", desc = "power menu (lock/logout/shutdown/reboot)", dispatch = "wlogout" },
	{ key = "a", desc = "power menu (lock/logout/shutdown/reboot)", dispatch = "wlogout" },

	-- This overview
	{
		key = "SHIFT + backslash",
		desc = "show this keybinding overview",
		dispatch = function()
			if hl.get_windows({ class = "hypr-binds" })[1] ~= nil then
				hl.dispatch(hl.dsp.focus({ window = "class:hypr-binds" }))
			else
				hl.exec_cmd("kitty --class hypr-binds --title keybindings -e less -M " .. overviewPath)
			end
		end,
	},

	{ header = "Focus" },
	{ key = "k", desc = "focus up", dispatch = hl.dsp.focus({ direction = "up" }) },
	{ key = "j", desc = "focus down", dispatch = hl.dsp.focus({ direction = "down" }) },
	{ key = "UP", desc = "focus up", dispatch = hl.dsp.focus({ direction = "up" }) },
	{ key = "DOWN", desc = "focus down", dispatch = hl.dsp.focus({ direction = "down" }) },
	{ key = "l", desc = "focus column right (or next monitor)", dispatch = focus_column_right },
	{ key = "h", desc = "focus column left (or previous monitor)", dispatch = focus_column_left },
	{ key = "RIGHT", desc = "focus column right (or next monitor)", dispatch = focus_column_right },
	{ key = "LEFT", desc = "focus column left (or previous monitor)", dispatch = focus_column_left },

	{ header = "Move columns" },
	---- (niri uses Ctrl; Shift kept from the old scheme)
	{ key = "SHIFT + h", desc = "swap column left", dispatch = hl.dsp.layout("swapcol l") },
	{ key = "SHIFT + l", desc = "swap column right", dispatch = hl.dsp.layout("swapcol r") },
	{ key = "CTRL + h", desc = "swap column left", dispatch = hl.dsp.layout("swapcol l") },
	{ key = "CTRL + l", desc = "swap column right", dispatch = hl.dsp.layout("swapcol r") },

	{ header = "Workspaces" },
	---- up/down (niri Mod+U/I)
	{ key = "u", desc = "next workspace", dispatch = hl.dsp.focus({ workspace = "e+1" }) },
	{ key = "i", desc = "previous workspace", dispatch = hl.dsp.focus({ workspace = "e-1" }) },
	{
		key = "CTRL + u",
		desc = "move window to next workspace",
		dispatch = hl.dsp.window.move({ workspace = "e+1", follow = true }),
	},
	{
		key = "CTRL + i",
		desc = "move window to previous workspace",
		dispatch = hl.dsp.window.move({ workspace = "e-1", follow = true }),
	},

	---- Special Workspaces
	{ key = "m", desc = "toggle music workspace", dispatch = hl.dsp.workspace.toggle_special("music") },
	{ key = "minus", desc = "toggle scratchpad", dispatch = hl.dsp.workspace.toggle_special("scratch") },
	{
		key = "SHIFT + minus",
		desc = "move window to scratchpad",
		dispatch = hl.dsp.window.move({ workspace = "special:scratch", follow = false }),
	},

	{ header = "Recording" },
	-- Youtuber mode lol
	{
		key = "z",
		desc = "toggle recording mode (wshowkeys)",
		dispatch = function()
			if recordingMode == 0 then
				recordingMode = 1
				hl.exec_cmd(
					"wshowkeys -a right -F 'FiraMono Nerd Font 35' -s '#cba6f7ff' -f  '#cdd6f4ff' -b '#45475a99' -m 70 -l 60 -t 1000 -a top"
				)
				notif("Recording Mode Enabled")
			else
				recordingMode = 0
				hl.exec_cmd("pkill wshowkeys")
				notif("Recording Mode Disabled")
			end
		end,
	},

	{
		key = "x",
		desc = "zoom (woomer, recording mode only)",
		dispatch = function()
			if recordingMode == 1 then
				hl.exec_cmd("woomer --output HDMI-A-2 --radius 2 --monitor HDMI-A-2 -S")
			end
		end,
	},

	{ header = "Screenshots" },
	{ mod = subMod, key = "SHIFT + s", desc = "screenshot area to clipboard", dispatch = "grimblast copy area" },

	{ header = "Mouse" },
	{
		mod = subMod,
		key = "mouse:272",
		desc = "drag to move window (left button)",
		dispatch = hl.dsp.window.drag(),
		opts = { mouse = true },
	},
	{
		mod = subMod,
		key = "mouse:272",
		desc = "click to float window (left button)",
		dispatch = hl.dsp.window.float(),
		opts = { mouse = true, click = true },
	},
	{
		mod = subMod,
		key = "mouse:272",
		dispatch = hl.dsp.layout("promote"),
		opts = { mouse = true, release = true },
	},
	{
		mod = subMod,
		key = "SHIFT + mouse:272",
		desc = "drag to resize window (left button)",
		dispatch = hl.dsp.window.resize(),
		opts = { mouse = true },
	},
	{
		mod = subMod,
		key = "mouse:273",
		desc = "drag to resize window (right button)",
		dispatch = hl.dsp.window.resize(),
		opts = { mouse = true },
	},
}

for _, bind in ipairs(globalAppBinds) do
	if bind.header then
		section(bind.header)
	else
		local modBind = bind.mod or mainMod
		local command
		if type(bind.dispatch) ~= "string" then
			command = bind.dispatch
		else
			command = hl.dsp.exec_cmd(bind.dispatch)
		end
		hl.bind(modBind .. bind.key, command, bind.opts or {})
		if bind.desc then
			note(modBind .. bind.key, bind.desc)
		end
	end
end

-- Workspaces on numbers like niri: SUPER+n focuses, +CTRL (niri) or
-- +SHIFT moves the window there
for index = 1, 9 do
	local key = tostring(index)
	hl.bind(mainMod .. key, hl.dsp.focus({ workspace = index }))
	hl.bind(mainMod .. "CTRL + " .. key, hl.dsp.window.move({ workspace = index, follow = false }))
	hl.bind(mainMod .. "SHIFT + " .. key, hl.dsp.window.move({ workspace = index, follow = false }))
end
note(mainMod .. "1..9", "focus workspace n")
note(mainMod .. "CTRL/SHIFT + 1..9", "move window to workspace n")

-- Screenshots without SUPER, like niri's Print family
section("Screenshots (no SUPER)")
hl.bind("PRINT", hl.dsp.exec_cmd("grimblast copy area"))
note("PRINT", "screenshot area to clipboard")
hl.bind("CTRL + PRINT", hl.dsp.exec_cmd("grimblast copy output"))
note("CTRL + PRINT", "screenshot monitor to clipboard")
hl.bind("ALT + PRINT", hl.dsp.exec_cmd("grimblast copy active"))
note("ALT + PRINT", "screenshot window to clipboard")

-- Media keys, usable on the lock screen
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

-- Playback keys (need playerctl installed)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { locked = true })
section("Media keys (work on the lock screen)")
note("XF86Audio*", "volume, mute, playback via wpctl/playerctl")

-- Write the overview for SUPER + \ to display
local overviewFile = io.open(overviewPath, "w")
if overviewFile then
	overviewFile:write(table.concat(overviewLines, "\n") .. "\n")
	overviewFile:close()
end
