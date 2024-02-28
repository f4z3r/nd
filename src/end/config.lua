local os = require("os")

local M = {}

local ENV_VAR_LOG_FILE = "END_LOG_FILE"

local DEFAULT_LOG_FILEPATH = "~/.local/state/end/end.log"

local function expand_home(path)
  local home = os.getenv("HOME")
  if home == nil then
    return path
  end
  local res, _ = path:gsub("~", home)
  return res
end

local function get_default_env(name, default)
  local val = os.getenv(name)
  if val == nil then
    return default
  end
  return val
end

--- Get the log file name as configured.
--- @return string
function M.get_log_file()
  return expand_home(get_default_env(ENV_VAR_LOG_FILE, DEFAULT_LOG_FILEPATH))
end

return M
