local str_utils = require("nd.utils.strings")

local toggle = {}

function toggle.register_command(parser)
  local _ = parser:command("toggle"):summary("Toggle the timer."):description(str_utils.trim_indents([[
    Start a timer if none is running, or stop the current timer if one is running.]]))
end

function toggle.execute(options)
  error("not implemented")
end

return toggle
