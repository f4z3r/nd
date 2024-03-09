local str_utils = require("nd.utils.strings")

local complete = require("nd.commands.complete")
local timer = require("nd.timer")

local skip = {}

function skip.register_command(parser)
  local _ =
    parser:command("skip"):summary("Skip the current or upcoming session."):description(str_utils.trim_indents([[
    Skip the currently running session, marking it as completed. If no session is
    running, skip the session that would be next.]]))
end

function skip.execute(options)
  complete.execute(options)
  timer.stop(true)
end

return skip
