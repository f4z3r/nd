local str_utils = require("nd.utils.strings")
local timer = require("nd.timer")

local start = {}

function start.register_command(parser)
  local start_parser = parser:command("start"):summary("Start the timer."):description(str_utils.trim_indents([[
    Start the pomodoro timers. This will auto-detect whether to launch a work, rest,
    or long-rest session.]]))
  start_parser:argument("type", "Force a work or rest session."):choices(timer.sessions_types()):args("?")
end

function start.execute(options)
  if timer.get_active() then
    print("Session already running")
    os.exit(1)
  end
  local session_type = options.type or timer.next_session_type()
  timer.start(session_type)
end

return start
