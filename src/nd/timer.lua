local io = require("io")
local math = require("math")
local os = require("os")
local string = require("string")

local date = require("date")
local json = require("rapidjson")

local str_utils = require("nd.utils.strings")

local SECOND_TO_MICROSECOND = 1000000
-- TODO make this configurable
local NOTIFICATION_SOUND = "/home/f4z3r/.local/share/uair/notification-sound.wav"
local CALLBACK = "nd complete"

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
      start = "Work session started. Let's focus for 25 minutes. No distractions!",
      stop = "Work session finished. Stand up, get a coffee, walk around a bit, stretch...",
    },
  },
  rest = {
    duration = date("00:05:00"),
    descriptions = {
      start = "Short break started. How about a coffee, some stretching, or a couple of push-ups?",
      stop = "Break done, let's get back to focused work!",
    },
  },
  ["long-rest"] = {
    duration = date("00:25:00"),
    descriptions = {
      start = "Long break started. Take the time to get some fresh air and move around.",
      stop = "Break done, let's get back to focused work!",
    },
  },
}

local timer = {}

---@alias SessionType "work" | "rest" | "long-rest"

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
  local cmd =
    string.format("systemd-run --on-active='%s' --user --unit %s %s 2> /dev/null", duration_str, service, CALLBACK)
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
        string.format(
          "Stopped timer '%s' with %dm left.",
          session_type_from_unit(t.unit),
          math.floor(left:spanminutes())
        ),
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
  local expires = date(t.left / SECOND_TO_MICROSECOND)
  local duration = date.diff(expires, date(true))
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
  local cmd = string.format(
    'notify-send "%s" "%s" -a nd -t %d -u %s -i tomato',
    str_utils.escape_quotes(title),
    str_utils.escape_quotes(description),
    timeout,
    level
  )
  if bell then
    cmd = cmd .. string.format(" && aplay %s 2> /dev/null &", NOTIFICATION_SOUND)
  end
  os.execute(cmd)
end

---return the next session type to launch
---@return SessionType
function timer.next_session_type()
  -- TODO actually implement
  return "work"
end

return timer
