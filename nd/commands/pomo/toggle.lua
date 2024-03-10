local str_utils = require("nd.utils.strings")

local toggle = {}

function toggle.register_command(parser)
  local _ = parser:command("toggle"):summary("Toggle the timer."):description(str_utils.trim_indents([[
    Start a timer if none is running, or stop the current timer if one is running.]]))
end

function toggle.execute(_)
  local timer = require("nd.timer")
  local entry_log = require("nd.entry_log")
  if timer.get_active() then
    timer.stop(true)
  else
    local session_type = entry_log.next_pomodoro_session_type()
    timer.start(session_type)
  end
end

return toggle
