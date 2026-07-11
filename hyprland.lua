hl.env("PATH", "/run/hypr-runtime-env/bin:" .. os.getenv("PATH"))
-- Get hostname from envvars or something
local handle = io.popen("hostname")
Hostname = "unknown" -- Default fallback

-- If there is a hostname at all
if handle then
	local result = handle:read("*l") -- Read the first line
	handle:close()
	if result then
		Hostname = result:gsub("%s+", "") -- Remove whitespace/newlines
	end
end

-- Import everything else
require("autoload")
