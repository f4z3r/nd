local entry_log = require("nd.entry_log")
local timer = require("nd.timer")

local complete = {}

function complete.register_command(parser)
  local _ = parser:command("complete"):hidden(true)
end

function complete.execute(_)
  local session_type = timer.get_active()
  if not session_type then
    session_type = entry_log.next_pomodoro_session_type()
  end
  entry_log.add_pomodoro(session_type)
  timer.notify_end(session_type)
end

return complete
