local date = require("date")
local utils = require("nd.utils")

local DATETIME_LEN = ("2023-05-31 12:30"):len()

local function extract_context(raw)
  local pattern = "@(%S+)"
  return raw:match(pattern)
end

local function extract_pomodoros(raw)
  local pattern = "%d%d%d%d%-%d%d%-%d%d %d%d:%d%d ([%*%+%-]*)"
  local pomo_str = raw:match(pattern)
  return pomo_str or ""
end

local function extract_project(raw)
  local pattern = "%d%d%d%d%-%d%d%-%d%d %d%d:%d%d [%*%+%-]*%s?(%S+):"
  local project = raw:match(pattern)
  if project ~= nil and project:sub(1, 1) == "!" then
    return project:sub(2)
  end
  return project
end

local function extract_description(raw)
  local pattern = "%d%d%d%d%-%d%d%-%d%d %d%d:%d%d [%*%+%-]*%s?%S+: (.+)$"
  local desc = raw:match(pattern)
  if desc ~= nil then
    return desc
  end
  pattern = "%d%d%d%d%-%d%d%-%d%d %d%d:%d%d [%*%+%-]*%s?(.+)$"
  return raw:match(pattern)
end

local function extract_tags(raw)
  local pattern = "%+(%S+)"
  local res = {}
  for match in raw:gmatch(pattern) do
    res[#res + 1] = match
  end
  return utils.Set:new(res)
end

local function extract_time(raw)
  local timestamp = raw:sub(1, DATETIME_LEN)
  return date(timestamp)
end

local entry = {}

entry.DATETIME_FMT = "%Y-%m-%d %H:%M"

---a log entry.
---@class Entry
---@field private _raw string
---@field timestamp table
---@field description string
---@field tags Set
---@field project string?
---@field context string?
---@field private _pomo_str string
local Entry = {}

---create a new entry.
---@param o table?
---@return Entry
function Entry:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

---create an Entry based on a string from the log file.
---@param raw string
---@return Entry
function Entry.from_str(raw)
  return Entry:new({
    _raw = raw,
    timestamp = extract_time(raw),
    project = extract_project(raw),
    description = extract_description(raw),
    context = extract_context(raw),
    tags = extract_tags(raw),
    _pomo_str = extract_pomodoros(raw),
  })
end

---return the number of minutes that elapsed since the other entry
---@param other Entry
---@return dateObject
function Entry:since(other)
  return self.timestamp - other.timestamp
end

---returns whether the entry is in the past
---@return boolean
function Entry:is_past()
  local now = date()
  return self.timestamp < now
end

---return the number of pomodoros in the entry
---@return integer
function Entry:pomodoros()
  local _, count = string.gsub(self._pomo_str, "%*", "*")
  return count
end

---return the number of breaks in the entry
---@return integer
function Entry:rests()
  local _, count = string.gsub(self._pomo_str, "%-", "-")
  return count
end

---return the number of long breaks in the entry
---@return integer
function Entry:long_rests()
  local _, count = string.gsub(self._pomo_str, "%+", "+")
  return count
end

function Entry:add_pomodoro()
  self._pomo_str = self._pomo_str .. "*"
end

function Entry:add_rest()
  self._pomo_str = self._pomo_str .. "-"
end

function Entry:add_long_rest()
  self._pomo_str = self._pomo_str .. "+"
end

function Entry:add_raw_pomo_str(pomo_str)
  self._pomo_str = self._pomo_str .. pomo_str
end

---@return SessionType?
function Entry:last_session()
  if self._pomo_str == "" then
    return nil
  end
  local last_chr = self._pomo_str:sub(self._pomo_str:len())
  if last_chr == "*" then
    return "work"
  elseif last_chr == "-" then
    return "rest"
  elseif last_chr == "+" then
    return "long-rest"
  end
end

function Entry:to_str()
  local res = self.timestamp:fmt(entry.DATETIME_FMT)
  if self._pomo_str ~= "" then
    res = res .. " " .. self._pomo_str
  end
  if self.project then
    res = res .. " " .. self.project .. ":"
  end
  res = res .. " " .. self.description
  return res
end

function Entry.__tostring(self)
  return self:to_str()
end

entry.Entry = Entry

return entry
