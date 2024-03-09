local math = require("math")
local os = require("os")

local M = {}

M.DEFAULT_EDITOR = "nvim"

---get env variable or return the default.
---@param name string
---@param default string
---@return string
function M.get_default_env(name, default)
  local val = os.getenv(name)
  if val == nil then
    return default
  end
  return val
end

---convert to integer
---@param val number
---@return number
function M.int(val)
  return math.floor(val)
end

local function filter_array(tbl, fun)
  local res = {}
  for _, val in ipairs(tbl) do
    if fun(val) then
      res[#res + 1] = val
    end
  end
  return res
end

local function filter_table(tbl, fun)
  local res = {}
  for key, val in pairs(tbl) do
    if fun(val) then
      res[key] = val
    end
  end
  return res
end

function M.filter(tbl, fun)
  local is_array = #tbl > 0
  if is_array then
    return filter_array(tbl, fun)
  else
    return filter_table(tbl, fun)
  end
end

local function map_array(tbl, fun)
  local res = {}
  for _, val in ipairs(tbl) do
    res[#res + 1] = fun(val)
  end
  return res
end

local function map_table(tbl, fun)
  local res = {}
  for key, val in pairs(tbl) do
    res[key] = fun(val)
  end
  return res
end

function M.map(tbl, fun)
  local is_array = #tbl > 0
  if is_array then
    return map_array(tbl, fun)
  else
    return map_table(tbl, fun)
  end
end

local function reduce_array(tbl, fun, init)
  init = init or 0
  for _, val in ipairs(tbl) do
    init = fun(init, val)
  end
  return init
end

local function reduce_table(tbl, fun, init)
  init = init or 0
  for key, val in pairs(tbl) do
    init = fun(init, key, val)
  end
  return init
end

function M.reduce(tbl, fun, init)
  local is_array = #tbl > 0
  if is_array then
    return reduce_array(tbl, fun, init)
  else
    return reduce_table(tbl, fun, init)
  end
end

---@class Set
local Set = {}

function Set:new(o)
  local obj = {
    _data = {},
  }
  o = o or {}
  for _, val in ipairs(o) do
    obj._data[val] = true
  end
  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Set:insert(val)
  self._data[val] = true
end

function Set:contains(val)
  return self._data[val] or false
end

function Set:remove(val)
  self._data[val] = nil
end

function Set:len()
  local count = 0
  for _, _ in pairs(self._data) do
    count = count + 1
  end
  return count
end

function Set:is_empty()
  return self:len() == 0
end

function Set:to_table()
  local res = {}
  for key, _ in pairs(self._data) do
    res[#res + 1] = key
  end
  return res
end

M.Set = Set

return M
