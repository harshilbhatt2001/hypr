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
hl.bind(mainMod .. " + backspace", hl.dsp.window.close())

hl.bind(mainMod .. "d", function()
	hl.notification.create({ text = tostring(hl.get_windows({ class = "otter" })[1]), timeout = 3000, icon = "ok" })
	if hl.get_windows({ class = "otter" })[1] ~= nil then
		hl.dsp.focus({ window = { class = "otter" } })
	else
		hl.exec_cmd("kitty --class otter --title otter-launcher -e sh -c 'sleep 0.05 && otter-launcher'")
	end
end)

-- Open windows
local globalAppBinds = {
	{ key = { "RETURN" }, dispatch = "kitty" },
	{ key = { "f", "o" }, dispatch = "firefox" },
	{ key = { "s" }, dispatch = "nemo" },
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

-- Move windows with hjkl
