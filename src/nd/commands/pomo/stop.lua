local str_utils = require("nd.utils.strings")

local timer = require("nd.timer")

local stop = {}

function stop.register_command(parser)
  local _ = parser:command("stop"):summary("Stop any current timer."):description(str_utils.trim_indents([[
    Stop any running timer. This will not mark the running timer as completed.]]))
end

function stop.execute(_)
  timer.stop(true)
end

return stop
