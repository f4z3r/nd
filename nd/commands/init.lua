local argparse = require("argparse")

local add = require("nd.commands.add")
local complete = require("nd.commands.complete")
local edit = require("nd.commands.edit")
local hello = require("nd.commands.hello")
local pomo = require("nd.commands.pomo")
local report = require("nd.commands.report")

local commands = {}

---parse the command line arguments.
---@return table
function commands.parse()
  local parser = argparse()
      :name("nd")
      :description("Time tracking tool that incorporates pomodoro timers and is plugin capable.")
      :epilog("For more information see: https://github.com/f4z3r/nd")
      :add_complete()
      :require_command(false)
      :command_target("command")

  hello.register_command(parser)
  add.register_command(parser)
  edit.register_command(parser)
  report.register_command(parser)
  pomo.register_command(parser)
  complete.register_command(parser)

  return parser:parse()
end

return commands
