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

-- Set modifier keys
local mainMod = "SUPER + "
local subMod = mainMod
local recordingMode = 0

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
local globalAppBinds = {

	---- Window functions
	{ key = "q", dispatch = hl.dsp.window.close() },
	{ key = "BACKSPACE", dispatch = hl.dsp.window.close() },
	{ key = "f", dispatch = hl.dsp.window.fullscreen({ action = "toggle", mode = "maximized" }) },
	{ key = "SHIFT + f", dispatch = hl.dsp.window.fullscreen({ action = "toggle" }) },
	{ key = "v", dispatch = hl.dsp.window.float() },
	{ mod = subMod, key = "space", dispatch = hl.dsp.window.float() },
	{ key = "SHIFT + e", dispatch = hl.dsp.exit() },

	---- Apps
	-- Browser
	{ key = "w", dispatch = "zen" },

	-- Launcher
	{
		key = "d",
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
		dispatch = function()
			if recordingMode == 1 then
				hl.exec_cmd("kitty -o font_size=24 -o window_margin_width=20")
			else
				hl.exec_cmd("kitty")
			end
		end,
	},

	-- File browser
	{ key = "s", dispatch = "nemo" },

	---- Focus
	{ key = "k", dispatch = hl.dsp.focus({ direction = "up" }) },
	{ key = "j", dispatch = hl.dsp.focus({ direction = "down" }) },
	{ key = "UP", dispatch = hl.dsp.focus({ direction = "up" }) },
	{ key = "DOWN", dispatch = hl.dsp.focus({ direction = "down" }) },
	{ key = "l", dispatch = focus_column_right },
	{ key = "h", dispatch = focus_column_left },
	{ key = "RIGHT", dispatch = focus_column_right },
	{ key = "LEFT", dispatch = focus_column_left },

	---- Move columns (niri uses Ctrl; Shift kept from the old scheme)
	{ key = "SHIFT + h", dispatch = hl.dsp.layout("swapcol l") },
	{ key = "SHIFT + l", dispatch = hl.dsp.layout("swapcol r") },
	{ key = "CTRL + h", dispatch = hl.dsp.layout("swapcol l") },
	{ key = "CTRL + l", dispatch = hl.dsp.layout("swapcol r") },

	---- Workspaces up/down (niri Mod+U/I)
	{ key = "u", dispatch = hl.dsp.focus({ workspace = "e+1" }) },
	{ key = "i", dispatch = hl.dsp.focus({ workspace = "e-1" }) },
	{ key = "CTRL + u", dispatch = hl.dsp.window.move({ workspace = "e+1", follow = true }) },
	{ key = "CTRL + i", dispatch = hl.dsp.window.move({ workspace = "e-1", follow = true }) },

	---- Special Workspaces
	{ key = "m", dispatch = hl.dsp.workspace.toggle_special("music") },
	{ key = "minus", dispatch = hl.dsp.workspace.toggle_special("scratch") },
	{ key = "SHIFT + minus", dispatch = hl.dsp.window.move({ workspace = "special:scratch", follow = false }) },

	-- Youtuber mode lol
	{
		key = "z",
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
		dispatch = function()
			if recordingMode == 1 then
				hl.exec_cmd("woomer --output HDMI-A-2 --radius 2 --monitor HDMI-A-2 -S")
			end
		end,
	},

	-- Logout menu
	{ key = "a", dispatch = "wlogout -b 5" },

	-- Screenshot
	{ mod = subMod, key = "SHIFT + s", dispatch = "grimblast copy area" },

	-- Mouse for moving windows
	{ mod = subMod, key = "mouse:272", dispatch = hl.dsp.window.drag(), opts = { mouse = true } },
	{ mod = subMod, key = "mouse:272", dispatch = hl.dsp.window.float(), opts = { mouse = true, click = true } },
	{
		mod = subMod,
		key = "mouse:272",
		dispatch = hl.dsp.layout("promote"),
		opts = { mouse = true, release = true },
	},
	{ mod = subMod, key = "SHIFT + mouse:272", dispatch = hl.dsp.window.resize(), opts = { mouse = true } },
	{ mod = subMod, key = "mouse:273", dispatch = hl.dsp.window.resize(), opts = { mouse = true } },
}

for _, bind in ipairs(globalAppBinds) do
	local modBind = bind.mod or mainMod
	local command
	if type(bind.dispatch) ~= "string" then
		command = bind.dispatch
	else
		command = hl.dsp.exec_cmd(bind.dispatch)
	end
	hl.bind(modBind .. bind.key, command, bind.opts or {})
end

-- Workspaces on numbers like niri: SUPER+n focuses, +CTRL (niri) or
-- +SHIFT moves the window there
for index = 1, 9 do
	local key = tostring(index)
	hl.bind(mainMod .. key, hl.dsp.focus({ workspace = index }))
	hl.bind(mainMod .. "CTRL + " .. key, hl.dsp.window.move({ workspace = index, follow = false }))
	hl.bind(mainMod .. "SHIFT + " .. key, hl.dsp.window.move({ workspace = index, follow = false }))
end

-- Screenshots without SUPER, like niri's Print family
hl.bind("PRINT", hl.dsp.exec_cmd("grimblast copy area"))
hl.bind("CTRL + PRINT", hl.dsp.exec_cmd("grimblast copy output"))
hl.bind("ALT + PRINT", hl.dsp.exec_cmd("grimblast copy active"))

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
