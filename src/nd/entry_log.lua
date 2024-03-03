local date = require("date")
local io = require("io")
local string = require("string")
local pth = require("path")

local config = require("nd.config")
local utils = require("nd.utils")

local DATETIME_LEN = ("2023-05-31 12:30"):len()

local function extract_context(raw)
  local pattern = "@(%S+)"
  return string.match(raw, pattern)
end

local function extract_pomodoros(raw)
  local pattern = "%d%d%d%d%-%d%d%-%d%d %d%d:%d%d (%**%-?)"
  local pomo_str = string.match(raw, pattern)
  if pomo_str == nil then return pomo_str, 0 end
  return pomo_str, pomo_str:gsub("-", ""):len()
end

local function extract_project(raw)
  local pattern = "%d%d%d%d%-%d%d%-%d%d %d%d:%d%d %**%-?%s?(%S+):"
  local project = string.match(raw, pattern)
  if project ~= nil and project:sub(1, 1) == "!" then return project:sub(2) end
  return project
end

local function extract_description(raw)
  local pattern = "%d%d%d%d%-%d%d%-%d%d %d%d:%d%d %**%-?%s?%S+: (.+)$"
  local desc = string.match(raw, pattern)
  if desc ~= nil then return desc end
  pattern = "%d%d%d%d%-%d%d%-%d%d %d%d:%d%d %**%-?%s?(.+)$"
  return string.match(raw, pattern)
end

local function extract_tags(raw)
  local pattern = "%+(%S+)"
  local res = {}
  for match in string.gmatch(raw, pattern) do
    res[#res + 1] = match
  end
  return utils.Set:new(res)
end

local function extract_time(raw)
  local timestamp = string.sub(raw, 1, DATETIME_LEN)
  return date(timestamp)
end

local M = {}

---a log entry.
---@class Entry
---@field timestamp table
---@field description string
---@field tags Set
---@field pomodoros number
---@field project string?
---@field context string?
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
function Entry.from_str(raw)
  local pomo_str, pomodoros = extract_pomodoros(raw)
  return Entry:new({
    raw = raw,
    timestamp = extract_time(raw),
    project = extract_project(raw),
    description = extract_description(raw),
    context = extract_context(raw),
    tags = extract_tags(raw),
    pomo_str = pomo_str,
    pomodoros = pomodoros,
  })
end

---return if the entry has an active pomodoro
---@return boolean
function Entry:is_active()
  return self.pomo_str:find("-") == #self.pomo_str
end

---return the number of minutes that elapsed since the other entry
---@param other Entry
---@return number
function Entry:since(other)
  local diff = self.timestamp - other.timestamp
  return diff:spanminutes()
end

---returns whether the entry is in the past
---@return boolean
function Entry:is_past()
  local now = date()
  return self.timestamp < now
end

M.Entry = Entry

---adds a raw string as an entry to the entry log with the current time.
---@param raw string
function M.add(raw, prefix)
  prefix = prefix or ""
  local out = assert(io.open(config.get_log_file(), "a+"))
  local now = date():fmt("%Y-%m-%d %H:%M")
  out:write(string.format("%s%s %s\n", prefix, now, raw))
  out:close()
end

---returns the entries from the entry log for the provided date.
---@param raw_date string Using the format 2024-02-28
---@return table
function M.get_entries(raw_date)
  local res = {}
  for line in assert(io.lines(config.get_log_file())) do
    if string.find(line, raw_date, nil, true) == 1 then
      res[#res + 1] = Entry.from_str(line)
    end
  end
  return res
end

---edit the entry log manually using the configured $EDITOR
function M.edit_log()
  local editor = utils.get_default_env("EDITOR", utils.DEFAULT_EDITOR)
  local flags = ""
  if editor == "nvim" or editor == "vim" then
    flags = "+"
  end
  local filename = config.get_log_file()
  os.execute(string.format("%s %s '%s'", editor, flags, filename))
end

---ensure the entry log directory exists so that the file can be created.
function M.ensure_exists()
  local filename = config.get_log_file()
  local dir = pth.dirname(filename)
  if not pth.exists(dir) then
    pth.mkdir(dir)
  end
end

return M
