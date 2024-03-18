local date = require("date")
local io = require("io")
local pth = require("path")
local string = require("string")

local config = require("nd.config")
local entry = require("nd.entry_log.entry")
local timer = require("nd.timer")

local function get_last_line()
  local filename = config.get_log_file()
  local fh = assert(io.open(filename, "r"))
  -- offset by one to skip trailing newline
  local length = fh:seek("end", -1)
  local res = 0
  if length > 1024 then
    res = fh:seek("end", -1024)
  else
    res = fh:seek("set")
  end
  local next = res
  local last_line = ""
  while next < length do
    res = fh:seek()
    last_line = fh:read("l")
    next = fh:seek()
  end
  fh:close()
  return last_line, res
end

local function update_last_line(str)
  local _, last_line_offset = get_last_line()
  local filename = config.get_log_file()
  local fh = assert(io.open(filename, "r+"))
  fh:seek("set", last_line_offset)
  fh:write(str)
  fh:close()
end

local entry_log = {}

---adds a raw string as an entry to the entry log with the current time.
---@param raw string
function entry_log.add(raw, prefix)
  prefix = prefix or ""
  local out = assert(io.open(config.get_log_file(), "a+"))
  local now = date():fmt(entry.DATETIME_FMT)
  if timer.is_cache_empty() then
    out:write(string.format("%s%s %s\n", prefix, now, raw))
  else
    local cache = timer.get_cache()
    out:write(string.format("%s%s %s %s\n", prefix, now, cache, raw))
    timer.wipe_cache()
  end
  out:close()
end

---returns the entries from the entry log for the provided date.
---@param raw_date string Using the format 2024-02-28
---@return Entry[]
function entry_log.get_entries(raw_date)
  local res = {}
  for line in assert(io.lines(config.get_log_file())) do
    if line:find(raw_date, nil, true) == 1 then
      res[#res + 1] = entry.Entry.from_str(line)
    end
  end
  return res
end

---edit the entry log manually using the configured $EDITOR
function entry_log.edit_log()
  local editor = config.get_editor()
  local flags = ""
  if editor == "nvim" or editor == "vim" then
    flags = "+"
  end
  local filename = config.get_log_file()
  os.execute(string.format("%s %s '%s'", editor, flags, filename))
end

---ensure the entry log directory exists so that the file can be created.
function entry_log.ensure_exists()
  local filename = config.get_log_file()
  local dir = pth.dirname(filename)
  if not pth.exists(dir) then
    pth.mkdir(dir)
  end
end

---add a pomodoro session to the last entry of the log
---@param session_type SessionType
function entry_log.add_pomodoro(session_type)
  local last_line = get_last_line()
  local val = entry.Entry.from_str(last_line)
  if not val:is_past() then
    timer.add_to_cache(session_type)
    return
  end
  if not timer.is_cache_empty() then
    local cache = timer.get_cache()
    val:add_raw_pomo_str(cache)
    timer.wipe_cache()
  end
  if session_type == "work" then
    val:add_pomodoro()
  elseif session_type == "rest" then
    val:add_rest()
  elseif session_type == "long-rest" then
    val:add_long_rest()
  end
  update_last_line(val:to_str() .. "\n")
end

function entry_log.next_pomodoro_session_type()
  local entries = entry_log.get_entries(date():fmt("%F"))
  local pomo_sum = 0
  local last = nil
  for _, ent in ipairs(entries) do
    pomo_sum = pomo_sum + ent:pomodoros()
    last = ent:last_session()
  end
  if not last or last == "long-rest" or last == "rest" then
    return "work"
  elseif pomo_sum % 4 == 0 then
    return "long-rest"
  else
    return "rest"
  end
end

return entry_log
