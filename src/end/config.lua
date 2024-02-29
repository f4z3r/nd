local pth = require("path")

local utils = require("end.utils")

local M = {}

local ENV_VAR_LOG_FILE = "END_LOG_FILE"

local DEFAULT_LOG_FILEPATH = "~/.local/state/end/end.log"

local function expand_home(path)
  local home = pth.user_home()
  if home == nil then return path end
  local res, _ = path:gsub("~", home)
  return res
end

---Get the log file name as configured.
---@return string
function M.get_log_file()
  return expand_home(utils.get_default_env(ENV_VAR_LOG_FILE, DEFAULT_LOG_FILEPATH))
end

return M
