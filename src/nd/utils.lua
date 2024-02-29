local os = require("os")
local string = require("string")
local table = require("table")

local M = {}

M.DEFAULT_EDITOR = "nvim"

---get env variable or return the default.
---@param name string
---@param default string
---@return string
function M.get_default_env(name, default)
  local val = os.getenv(name)
  if val == nil then return default end
  return val
end

---split multiline string into table of lines.
---@param str string
---@return table
function M.split_into_lines(str)
  local delimiter = "\n"
  local result = {}
  local from = 1
  local delim_from, delim_to = string.find(str, delimiter, from)
  while delim_from do
    table.insert(result, string.sub(str, from, delim_from - 1))
    from = delim_to + 1
    delim_from, delim_to = string.find(str, delimiter, from)
  end
  table.insert(result, string.sub(str, from))
  return result
end

---trim indents from multiline strings.
---@param str string
---@return string
function M.trim_indents(str)
  local lines = M.split_into_lines(str)
  local _, indent = lines[1]:find("%S")
  indent = indent or 1
  local res = {}
  for _, line in ipairs(lines) do
    res[#res + 1] = line:sub(indent)
  end
  return table.concat(res, "\n")
end

return M
