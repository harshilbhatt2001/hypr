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

-- Keybinding overview: every bind below carries a desc; they are collected
-- here and written to a text file on config (re)load.
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

-- App launcher (otter in a kitty window); bound via the shared keymap's
-- `launcher` action below
local function launcher_toggle()
	if hl.get_windows({ class = "otter" })[1] ~= nil then
		hl.dispatch(hl.dsp.focus({ window = "class:otter" }))
	else
		hl.exec_cmd("kitty --class otter --title otter-launcher -e sh -c 'sleep 0.05 && otter-launcher'")
	end
end

-- Hyprland-only binds. Everything both compositors share (close/maximize/
-- fullscreen/float/quit, terminal/browser/launcher, focus and move, numbered
-- and next/prev workspaces, screenshots, media keys, thumb wheel) comes from
-- the shared keymap loaded at the bottom of this file — add such binds in
-- modules/features/keymap in the nixos repo, not here.
-- Entries with `header` only mark sections in the overview.
local globalAppBinds = {

	{ header = "Windows" },
	{ mod = subMod, key = "space", desc = "toggle floating", dispatch = hl.dsp.window.float() },

	{ header = "Apps" },
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

	-- File browser (was SUPER + s; that key is the shared `music` action now)
	{ key = "e", desc = "file browser (nemo)", dispatch = "nemo" },

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

	{ header = "Move columns" },
	---- Shift variants kept from the old scheme (the shared keymap has Ctrl)
	{ key = "SHIFT + h", desc = "swap column left", dispatch = hl.dsp.layout("swapcol l") },
	{ key = "SHIFT + l", desc = "swap column right", dispatch = hl.dsp.layout("swapcol r") },

	{ header = "Workspaces" },
	---- Special Workspaces
	{ key = "m", desc = "toggle music workspace", dispatch = hl.dsp.workspace.toggle_special("music") },
	{ key = "minus", desc = "toggle scratchpad", dispatch = hl.dsp.workspace.toggle_special("scratch") },
	{
		key = "SHIFT + minus",
		desc = "move window to scratchpad",
		dispatch = hl.dsp.window.move({ workspace = "special:scratch", follow = false }),
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

-- SUPER+SHIFT+n moves the window to workspace n (old scheme; SUPER+n and
-- SUPER+CTRL+n come from the shared keymap)
for index = 1, 9 do
	hl.bind(mainMod .. "SHIFT + " .. tostring(index), hl.dsp.window.move({ workspace = index, follow = false }))
end
note(mainMod .. "SHIFT + 1..9", "move window to workspace n")

-- Shared keymap. modules/features/keymap in the nixos repo holds the binds
-- both compositors have in common and renders them to /run/hypr/keymap.lua
-- at rebuild time (features/hyprland links it there). Each entry is
-- { key, action, args, desc, locked }; this table turns the
-- compositor-neutral action into a hyprland dispatcher. An action without a
-- handler here raises a notification instead of silently doing nothing.
local sharedActions = {
	["spawn"] = function(b)
		return hl.dsp.exec_cmd(table.concat(b.args, " "))
	end,
	["launcher"] = function()
		return launcher_toggle
	end,
	-- YouTube Music scratchpad: same idiom as the scratchpad terminal — one
	-- persistent ytmdesktop on special:music (window rule in rules.lua),
	-- spawned on first use, then only shown/hidden so playback never stops.
	["music"] = function()
		return function()
			if hl.get_windows({ class = "YouTube Music Desktop App" })[1] == nil
				and hl.get_windows({ class = "youtube-music-desktop-app" })[1] == nil then
				hl.exec_cmd("ytmdesktop")
			end
			hl.dispatch(hl.dsp.workspace.toggle_special("music"))
		end
	end,
	["close-window"] = function()
		return hl.dsp.window.close()
	end,
	["quit"] = function()
		return hl.dsp.exit()
	end,
	["toggle-floating"] = function()
		return hl.dsp.window.float()
	end,
	["maximize"] = function()
		return hl.dsp.window.fullscreen({ action = "toggle", mode = "maximized" })
	end,
	["fullscreen"] = function()
		return hl.dsp.window.fullscreen({ action = "toggle" })
	end,
	["focus-left"] = function()
		return focus_column_left
	end,
	["focus-right"] = function()
		return focus_column_right
	end,
	["focus-up"] = function()
		return hl.dsp.focus({ direction = "up" })
	end,
	["focus-down"] = function()
		return hl.dsp.focus({ direction = "down" })
	end,
	["move-left"] = function()
		return hl.dsp.layout("swapcol l")
	end,
	["move-right"] = function()
		return hl.dsp.layout("swapcol r")
	end,
	["move-up"] = function()
		return hl.dsp.window.move({ direction = "up" })
	end,
	["move-down"] = function()
		return hl.dsp.window.move({ direction = "down" })
	end,
	["focus-workspace"] = function(b)
		return hl.dsp.focus({ workspace = b.args[1] })
	end,
	["move-to-workspace"] = function(b)
		return hl.dsp.window.move({ workspace = b.args[1], follow = false })
	end,
	["focus-workspace-next"] = function()
		return hl.dsp.focus({ workspace = "e+1" })
	end,
	["focus-workspace-prev"] = function()
		return hl.dsp.focus({ workspace = "e-1" })
	end,
	["move-to-workspace-next"] = function()
		return hl.dsp.window.move({ workspace = "e+1", follow = true })
	end,
	["move-to-workspace-prev"] = function()
		return hl.dsp.window.move({ workspace = "e-1", follow = true })
	end,
	["screenshot-area"] = function()
		return hl.dsp.exec_cmd("grimblast copy area")
	end,
	["screenshot-screen"] = function()
		return hl.dsp.exec_cmd("grimblast copy output")
	end,
	["screenshot-window"] = function()
		return hl.dsp.exec_cmd("grimblast copy active")
	end,
}

local keymapPath = "/run/hypr/keymap.lua"
local loaded, shared = pcall(dofile, keymapPath)
if loaded and type(shared) == "table" then
	section("Shared keymap (nixos modules/features/keymap)")
	for _, b in ipairs(shared) do
		local toDispatcher = sharedActions[b.action]
		if toDispatcher then
			hl.bind(b.key, toDispatcher(b), { locked = b.locked })
			if b.desc ~= "" then
				note(b.key, b.desc)
			end
		else
			notif("keymap: no hyprland handler for action '" .. tostring(b.action) .. "' (" .. b.key .. ")", 8000, "warning")
		end
	end
else
	notif("keymap: could not load " .. keymapPath .. "\n" .. tostring(shared), 8000, "warning")
end

-- Write the overview for SUPER + \ to display
local overviewFile = io.open(overviewPath, "w")
if overviewFile then
	overviewFile:write(table.concat(overviewLines, "\n") .. "\n")
	overviewFile:close()
end
