local pth = require("path")

local utils = require("nd.utils")

local ENV_VAR_LOG_FILE = "ND_LOG_FILE"
local DEFAULT_LOG_FILEPATH = "~/.local/state/nd/nd.log"

local function expand_home(path)
  local home = pth.user_home()
  if home == nil then return path end
  local res, _ = path:gsub("~", home)
  return res
end

local M = {}

---get the log file name as configured.
---@return string
function M.get_log_file()
  return expand_home(utils.get_default_env(ENV_VAR_LOG_FILE, DEFAULT_LOG_FILEPATH))
end

return M
