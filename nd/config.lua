local pth = require("path")

local utils = require("nd.utils")

local ENV_VAR_LOG_FILE = "ND_LOG_FILE"
local ENV_VAR_CACHE_FILE = "ND_CACHE_FILE"
local DEFAULT_LOG_FILEPATH = "~/.local/state/nd/nd.log"
local DEFAULT_CACHE_FILEPATH = "~/.local/state/nd/cache"
local DEFAULT_EDITOR = "nvim"

local function expand_home(path)
  local home = pth.user_home()
  if home == nil then
    return path
  end
  local res, _ = path:gsub("~", home)
  return res
end

local config = {}

---get the log file name as configured.
---@return string
function config.get_log_file()
  return expand_home(utils.get_default_env(ENV_VAR_LOG_FILE, DEFAULT_LOG_FILEPATH))
end

---get the log file name as configured.
---@return string
function config.get_editor()
  return utils.get_default_env("EDITOR", DEFAULT_EDITOR)
end

---get the cache file name as configured.
---@return string
function config.get_cache_file()
  return expand_home(utils.get_default_env(ENV_VAR_CACHE_FILE, DEFAULT_CACHE_FILEPATH))
end

return config
