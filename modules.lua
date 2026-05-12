-- loader.lua
local function get_modules()
	local modules = {}

	-- -1: list one file per line
	-- ../modules/*.lua: target sibling directory
	local cmd = "ls -1 ../modules/*.lua 2>/dev/null"

	local p = io.popen(cmd)
	if not p then
		return modules
	end

	for path in p:lines() do
		-- Extract the filename between the last '/' and the '.lua'
		local name = path:match("([^/]+)%.lua$")
		if name then
			table.insert(modules, name)
		end
	end

	p:close()
	return modules
end

-- Return the result of the function so require("loader")
-- gives you the table immediately.
return get_modules()
