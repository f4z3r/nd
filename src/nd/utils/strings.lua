local table = require("table")

local strings = {}

---escape quotes in string
---@param str string
---@return string
function strings.escape_quotes(str)
  local res, _ = str:gsub("'", "\\'")
  res, _ = res:gsub('"', '\\"')
  return res
end

---split multiline string into table of lines
---@param str string
---@return string[]
function strings.split_into_lines(str)
  local delimiter = "\n"
  local result = {}
  local from = 1
  local delim_from, delim_to = str:find(delimiter, from)
  while delim_from do
    table.insert(result, str:sub(from, delim_from - 1))
    from = delim_to + 1
    delim_from, delim_to = str:find(delimiter, from)
  end
  table.insert(result, str:sub(from))
  return result
end

---trim indents from multiline strings.
---@param str string
---@return string
function strings.trim_indents(str)
  local lines = strings.split_into_lines(str)
  local _, indent = lines[1]:find("%S")
  indent = indent or 1
  local res = {}
  for _, line in ipairs(lines) do
    res[#res + 1] = line:sub(indent)
  end
  return table.concat(res, "\n")
end

return strings
