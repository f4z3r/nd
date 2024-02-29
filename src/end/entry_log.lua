local date = require("date")
local io = require("io")
local string = require("string")

local config = require("end.config")
local utils = require("end.utils")

local DATETIME_LEN = ("2023-05-31 12:30"):len()

local M = {}

M.Entry = {}

---Create a new entry
function M.Entry:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local function extract_context(raw)
  local pattern = "@(%S+)"
  return string.match(raw, pattern)
end

local function extract_pomodoros(raw)
  local pattern = "%d%d%d%d%-%d%d%-%d%d %d%d:%d%d (%**%-?)"
  return string.match(raw, pattern)
end

local function extract_project(raw)
  local pattern = "%d%d%d%d%-%d%d%-%d%d %d%d:%d%d %**%-? (%S+):"
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
  return res
end

local function extract_time(raw)
  local timestamp = string.sub(raw, 1, DATETIME_LEN)
  return date(timestamp)
end

---Create an Entry based on a string from the log file.
---@param raw string
function M.Entry.from_str(raw)
  return M.Entry:new({
    timestamp = extract_time(raw),
    project = extract_project(raw),
    description = extract_description(raw),
    context = extract_context(raw),
    tags = extract_tags(raw),
    pomo_str = extract_pomodoros(raw),
  })
end

---Return the number of completed pomodoros in this entry.
---@return number
function M.Entry:pomodoros()
  if self.pomo_str == nil then return 0 end
  return self.pomo_str:gsub("-", ""):len()
end

---Adds a raw string as an entry to the entry log with the current time.
---@param raw string
function M.add(raw)
  local out = assert(io.open(config.get_log_file(), "a+"))
  local now = date():fmt("%Y-%m-%d %H:%M")
  out:write(string.format("\n%s %s", now, raw))
  out:close()
end

---Returns the last entry in the entry log.
---@return string
function M.get_last_entry()
  local lines = assert(io.lines(config.get_log_file()))
  return M.Entry.from_str(lines[#lines])
end

---Returns the entries from the entry log for the provided date.
---@param raw_date string Using the format 2024-02-28
---@return table
function M.get_entries(raw_date)
  local res = {}
  for line in assert(io.lines(config.get_log_file())) do
    if string.find(line, raw_date, nil, true) ~= 1 then
      goto continue
    end
    res[#res + 1] = M.Entry.from_str(line)
    ::continue::
  end
  return res
end

---Edit the entry log manually using the configured $EDITOR
function M.edit_log()
  local editor = utils.get_default_env("EDITOR", utils.DEFAULT_EDITOR)
  local flags = ""
  if editor == "nvim" or editor == "vim" then
    flags = "+"
  end
  local filename = config.get_log_file()
  os.execute(string.format("%s %s '%s'", editor, flags, filename))
end

return M
