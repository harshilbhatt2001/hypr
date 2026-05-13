-- Set modifier keys
local mainMod = "SUPER + "
local subMod = mainMod
local keyboardString = "qwertyuiop"
local keybindIndex = 1

-- Set different modifiers on laptop
if Hostname == "mobile02" then
	mainMod = "ALT + "
	subMod = "SUPER + "
	keyboardString = "1234567890"
	keybindIndex = 2
end

-- Delete windows
hl.bind(mainMod .. "backspace", hl.dsp.window.close())

-- If otter is open, focus it, if not make a new window
hl.bind(mainMod .. "d", function()
	if hl.get_windows({ class = "otter" })[1] ~= nil then
		hl.dispatch(hl.dsp.focus({ window = "class:otter" }))
	else
		hl.exec_cmd("kitty --class otter --title otter-launcher -e sh -c 'sleep 0.05 && otter-launcher'")
	end
end)

-- Open windows
local globalAppBinds = {
	{ key = { "RETURN" }, dispatch = "kitty" },
	{ key = { "f", "o" }, dispatch = "firefox" },
	{ key = { "s" }, dispatch = "nemo" },
	{ key = { "a", "e" }, dispatch = "wlogout -b 5" },
}

for _, bind in ipairs(globalAppBinds) do
	if bind.key[keybindIndex] then
		hl.bind(mainMod .. bind.key[keybindIndex], hl.dsp.exec_cmd(bind.dispatch))
	else
		hl.bind(mainMod .. bind.key[1], hl.dsp.exec_cmd(bind.dispatch))
	end
end

-- Workspace functions
local keyboardSplit = {}

for char in keyboardString:gmatch(".") do
	table.insert(keyboardSplit, char)
end

for index, bind in ipairs(keyboardSplit) do
	hl.bind(mainMod .. bind, hl.dsp.focus({ workspace = index }))
	hl.bind(mainMod .. "SHIFT + " .. bind, hl.dsp.window.move({ workspace = index, follow = false }))
end

-- Music workspace
hl.bind(mainMod .. "m", hl.dsp.workspace.toggle_special("music"))

-- Move windows with hjkl
hl.bind(mainMod .. "SHIFT + h", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. "SHIFT + l", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. "k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. "j", hl.dsp.focus({ direction = "down" }))

-- Function to get window position relative to monitor
local function normalise_current_window_pos()
	local active = hl.get_active_window()
	if active then
		local xpos = active.at.x
		-- If on right monitor
		if xpos > 1920 then
			xpos = xpos - 1920
			return xpos
		-- If on left monitor
		elseif xpos < 1 then
			xpos = xpos + 1920
			return xpos
		else
			return xpos
		end
	end
end

hl.bind(mainMod .. "h", function()
	local pos = normalise_current_window_pos()
	if pos then
		-- 9 derived from 5 gap plus 3 border (8), so first pixel of window is 9
		if pos == 9 then
			-- If first window, then move to monitor to the left
			hl.dispatch(hl.dsp.focus({ monitor = "-1" }))
		end
	end
	hl.dispatch(hl.dsp.layout("move -col"))
end)

hl.bind(mainMod .. "l", function()
	-- Move before so you can detect if it is the last window
	hl.dispatch(hl.dsp.layout("move +col"))
	if not normalise_current_window_pos() then
		-- Go back a window
		hl.dispatch(hl.dsp.layout("move -col"))
		-- Move to monitor to the right
		hl.dispatch(hl.dsp.focus({ monitor = "+1" }))
	end
end)

-- Fullscreen with b
hl.bind(mainMod .. "b", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Special workspace
hl.bind(mainMod .. "minus", hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mainMod .. "SHIFT + minus", hl.dsp.window.move({ workspace = "special:scratch", follow = false }))

-- Float resize and move window with mouse
hl.bind(subMod .. "mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(subMod .. "mouse:272", hl.dsp.window.float(), { mouse = true, click = true })
hl.bind(subMod .. "mouse:272", hl.dsp.layout("promote"), { mouse = true, release = true })

hl.bind(subMod .. "SHIFT + mouse:272", hl.dsp.window.resize(), { mouse = true })
