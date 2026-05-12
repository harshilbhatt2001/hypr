local mainMod = "SUPER + "
local binds = {
	{ key = "x", dispatch = "kitty" },
}

for _, bind in ipairs(binds) do
	hl.bind(mainMod .. bind.key, hl.dsp.exec_cmd(bind.dispatch))
end
