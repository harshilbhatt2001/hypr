hl.env("PATH", "/run/hypr-runtime-env/bin:" .. os.getenv("PATH"))

-- Import everything else
require("autoload")
