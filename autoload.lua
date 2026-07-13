-- ~/.config/hypr/autoload.lua

-- Path to search
local modules

if os.getenv("MODULES_ROOT") then
	modules = os.getenv("MODULES_ROOT")
else
	modules = os.getenv("HOME") .. "/.config/hypr/modules"
end

-- Get all files in modules dir
local p = io.popen('find -L "' .. modules .. '" -name "*.lua" -type f | sort')
if not p then
	return
end

-- Recursively search and return modules
for path in p:lines() do
	local ok, err = pcall(dofile, path)
	-- If you fucked up the syntax like an idiot
	if not ok then
		hl.notification.create({
			text = "autoload: " .. path .. "\n" .. tostring(err),
			timeout = 8000,
			icon = "warning",
		})
	end
end

p:close()
