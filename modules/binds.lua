local mainMod = "SUPER + "
local subMod = mainMod
local keyboardString = "qwertyuiop"

if Hostname == "mobile02" then
	mainMod = "ALT + "
	subMod = "SUPER + "
	keyboardString = "1234567890"
end

-- Delete windows
hl.bind(mainMod .. " + backspace", hl.dsp.window.close())

-- Open windows
local globalAppBinds = {
	{ key = "RETURN", dispatch = "kitty" },
	{ key = "f", dispatch = "firefox" },
	{ key = "s", dispatch = "nemo" },
}

for _, bind in ipairs(globalAppBinds) do
	hl.bind(mainMod .. bind.key, hl.dsp.exec_cmd(bind.dispatch))
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

-- Move windows with hjkl
