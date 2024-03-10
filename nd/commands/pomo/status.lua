local str_utils = require("nd.utils.strings")

local status = {}

function status.register_command(parser)
  local status_parser =
    parser:command("status"):summary("Print the current status of the pomodoro."):description(str_utils.trim_indents([[
      Print the status of the running session and additional information about the day.]]))
  -- TODO set default format and document in README.
  status_parser:argument("format", "Format in which to print the status.", "default_format")
end

function status.execute(_)
  local timer = require("nd.timer")
  local name, _ = timer.get_active()
  if not name then
    print("-")
  else
    print(name)
  end
end

return status
