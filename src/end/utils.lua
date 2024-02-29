local os = require("os")

local M = {}

M.DEFAULT_EDITOR = "nvim"

---Get env variable or return the default.
---@param name string
---@param default string
---@return string
function M.get_default_env(name, default)
  local val = os.getenv(name)
  if val == nil then return default end
  return val
end

return M
