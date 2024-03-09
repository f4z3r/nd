local io = require("io")
local os = require("os")
local string = require("string")

local date = require("date")
local json = require("rapidjson")

local utils = require("nd.utils")

local SECOND_TO_MICROSECOND = 1000000
local NOTIFICATION_SOUND = "/home/f4z3r/.local/share/uair/notification-sound.wav"

local function expiry_to_duration(expires)
  expires = date(expires / SECOND_TO_MICROSECOND)
  return date.diff(expires, date(true))
end

local function unit_to_category(unit)
  return string.gsub(string.gsub(unit, "^nd%-", ""), ".timer$", "")
end

local function category_to_service(category)
  return "nd-" .. category .. ".service"
end

local timer = {}

---@alias dateObject table The type returned from `date` calls of LuaDate.

---@alias TimerCategory "work" | "rest"

---Start a timer for duration with a title and description. The callback will be called when the timer expires.
---@param duration dateObject
---@param callback string
---@param cat TimerCategory
---@param description string
---@param notify boolean?
function timer.start(duration, callback, cat, description, notify)
  local duration_str = string.format("%dm", utils.int(duration:spanminutes()))
  local service = category_to_service(cat)
  -- TODO escape title and validate not already running
  local cmd =
      string.format("systemd-run --on-active='%s' --user --unit %s %s 2> /dev/null", duration_str, service, callback)
  os.execute(cmd)
  if notify then
    local desc = string.format("Type: <u>%s</u>\n%s", cat, description)
    timer.notify("low", "nd: started a pomodoro timer", desc, 5)
  end
end

local function get_active_systemd_timers()
  local pid = assert(io.popen("systemctl list-timers --user -o json 'nd-*'"))
  local out = pid:read("*a")
  pid:close()
  return json.decode(out)
end

function timer.stop(notify)
  local timers = get_active_systemd_timers()
  for _, t in ipairs(timers) do
    os.execute(string.format("systemctl --user stop %s", t.unit))
    if notify then
      local left = expiry_to_duration(t.left)
      timer.notify(
        "low",
        "Timer stopped",
        string.format("Stopped timer '%s' with %dm left.", unit_to_category(t.unit), utils.int(left:spanminutes())),
        5
      )
    end
  end
end

---return the active timer, returns nil if no timer is active
---@return string?
---@return dateObject?
function timer.get_active()
  local timers = get_active_systemd_timers()
  if #timers > 1 then
    -- TODO add proper logging
    print("found more than one active timer ...")
  end
  if #timers == 0 then
    return nil, nil
  end
  local t = timers[1]
  local name = unit_to_category(t.unit)
  local expires = date(t.left / SECOND_TO_MICROSECOND)
  local duration = date.diff(expires, date(true))
  return name, duration
end

---@alias NotificationLevel "low" | "normal" | "critical"

---send a notification to the user via libnotify
---@param level NotificationLevel
---@param title string
---@param description string
---@param timeout number in seconds
---@param bell boolean?
function timer.notify(level, title, description, timeout, bell)
  timeout = timeout * 1000
  local cmd = string.format(
    'notify-send "%s" "%s" -a nd -t %d -u %s -i tomato',
    utils.string_escape(title),
    utils.string_escape(description),
    timeout,
    level
  )
  if bell then
    -- TODO make this sound configurable
    cmd = cmd .. string.format(" && aplay %s 2> /dev/null &", NOTIFICATION_SOUND)
  end
  os.execute(cmd)
end

return timer
