local io = require("io")
local math = require("math")
local os = require("os")
local string = require("string")

local date = require("date")
local pth = require("path")
local json = require("rapidjson")

local config = require("nd.config")

local SECOND_TO_MICROSECOND = 1000000
-- TODO make this configurable
local NOTIFICATION_SOUND = "/home/f4z3r/.local/share/uair/notification-sound.wav"
local CALLBACK = "nd complete"
local CALLBACK_ENV = "-E PATH -E DISPLAY -E DBUS_SESSION_BUS_ADDRESS -E ND_LOG_FILE -E ND_CACHE_FILE"

local function expiry_to_duration(expires)
  expires = date(expires / SECOND_TO_MICROSECOND)
  return date.diff(expires, date(true))
end

local function session_type_from_unit(unit)
  return string.gsub(string.gsub(unit, "^nd%-", ""), ".timer$", "")
end

local function service_name_from_session_type(category)
  return "nd-" .. category .. ".service"
end

local DEFAULTS = {
  work = {
    duration = date("00:25:00"),
    descriptions = {
      start = "Work session started. Focus for 25 minutes. No distractions!",
      stop = "Work session finished. Stand up, get a coffee, walk around a bit, stretch...",
    },
  },
  rest = {
    duration = date("00:05:00"),
    descriptions = {
      start = "Short break started. How about a coffee, some stretching, or a couple of push-ups?",
      stop = "Break done, get back to focused work!",
    },
  },
  ["long-rest"] = {
    duration = date("00:25:00"),
    descriptions = {
      start = "Long break started. Take the time to get some fresh air and move around.",
      stop = "Break done, get back to focused work!",
    },
  },
}

local timer = {}

timer.SESSION_MAP = {
  work = "*",
  rest = "-",
  ["long-rest"] = "+"
}


---return the types of sessions that are available
---@return string[]
function timer.sessions_types()
  return { "work", "rest", "long-rest" }
end

---start a timer
---@param session_type SessionType the type of session to start
function timer.start(session_type)
  local session_defaults = DEFAULTS[session_type]
  local duration_str = string.format("%dm", math.floor(session_defaults.duration:spanminutes()))
  local service = service_name_from_session_type(session_type)
  local cmd = string.format(
    "systemd-run --on-active='%s' --timer-property=AccuracySec=1s --user %s --unit %s %s 2> /dev/null",
    duration_str,
    CALLBACK_ENV,
    service,
    CALLBACK
  )
  os.execute(cmd)
  local desc = string.format("Type: <u>%s</u>\n%s", session_type, session_defaults.descriptions.start)
  timer.notify("low", "nd: started a pomodoro timer", desc, 5)
end

local function get_active_systemd_timers()
  local pid = assert(io.popen("systemctl list-timers --user -o json 'nd-*'"))
  local out = pid:read("*a")
  pid:close()
  return json.decode(out)
end

---stop any currently active timers
---@param notify boolean? whether to notify of the stopped timers
function timer.stop(notify)
  local timers = get_active_systemd_timers()
  for _, t in ipairs(timers) do
    os.execute(string.format("systemctl --user stop %s", t.unit))
    if notify then
      local left = expiry_to_duration(t.left)
      timer.notify(
        "low",
        "Timer stopped",
        string.format("Stopped timer %s with %dm left.", session_type_from_unit(t.unit), math.floor(left:spanminutes())),
        5
      )
    end
  end
end

---@alias dateObject table The type returned from `date` calls of LuaDate.

---return the active timer, returns nil if no timer is active
---@return string? name the session type that is currently active
---@return dateObject? duration remaining duration for the active timer
function timer.get_active()
  local timers = get_active_systemd_timers()
  if #timers > 1 then
    print("found more than one active timer ...")
  end
  if #timers == 0 then
    return nil, nil
  end
  local t = timers[1]
  local name = session_type_from_unit(t.unit)
  local duration = date("00:00:00")
  if type(t.left) == "number" then
    local expires = date(t.left / SECOND_TO_MICROSECOND)
    duration = date.diff(expires, date(true))
  end
  return name, duration
end

---@alias NotificationLevel "low" | "normal" | "critical"

---send a notification to the user via libnotify
---@param level NotificationLevel
---@param title string
---@param description string
---@param timeout integer how long to show the notification in seconds
---@param bell boolean? whether to play a sound for the notification
function timer.notify(level, title, description, timeout, bell)
  timeout = timeout * 1000
  local notif_cmd =
    string.format('notify-send "%s" "%s" -a nd -t %d -u %s -i tomato', title, description, timeout, level)
  os.execute(string.format("sh -c '%s'", notif_cmd))
  if bell then
    local bell_cmd = string.format("aplay -D default %s", NOTIFICATION_SOUND)
    os.execute(string.format("sh -c '%s'", bell_cmd))
  end
end

---add a session to the session cache
---@param session_type SessionType
function timer.add_to_cache(session_type)
  local cache_filename = config.get_cache_file()
  local fh = assert(io.open(cache_filename, "a+"))
  fh:write(timer.SESSION_MAP[session_type])
  fh:close()
end


---retrieve the session cache contents
---@return string
function timer.get_cache()
  local cache_filename = config.get_cache_file()
  local fh = assert(io.open(cache_filename, "r"))
  local out = fh:read("*l")
  fh:close()
  return out
end

function timer.ensure_cache_exists()
  local cache_filename = config.get_cache_file()
  local dir = pth.dirname(cache_filename)
  if not pth.exists(dir) then
    pth.mkdir(dir)
  end
end

function timer.wipe_cache()
  local cache_filename = config.get_cache_file()
  pth.remove(cache_filename)
end

function timer.is_cache_empty()
  local cache_filename = config.get_cache_file()
  return pth.exists(cache_filename)
end

function timer.notify_end(session_type)
  local session_defaults = DEFAULTS[session_type]
  local desc = string.format("Type: <u>%s</u>\n%s", session_type, session_defaults.descriptions.stop)
  timer.notify("critical", "nd: a pomodoro timer completed", desc, 15, true)
end

return timer
