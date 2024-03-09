local skip = require("nd.commands.pomo.skip")
local start = require("nd.commands.pomo.start")
local status = require("nd.commands.pomo.status")
local stop = require("nd.commands.pomo.stop")
local toggle = require("nd.commands.pomo.toggle")

local pomo = {}

function pomo.register_command(parser)
  local cmd_parser = parser
    :command("pomo")
    :summary("Pomodoro timer.")
    :description("Interact with the integrated pomodoro timer.")
    :command_target("pomo_command")

  start.register_command(cmd_parser)
  toggle.register_command(cmd_parser)
  stop.register_command(cmd_parser)
  status.register_command(cmd_parser)
  skip.register_command(cmd_parser)
end

function pomo.execute(options)
  local cmd = options.pomo_command
  if cmd == "start" then
    start.execute(options)
  elseif cmd == "toggle" then
    toggle.execute(options)
  elseif cmd == "stop" then
    stop.execute(options)
  elseif cmd == "status" then
    status.execute(options)
  elseif cmd == "skip" then
    skip.execute(options)
  else
    error("this code should not be reachable; missing switch in pomo.execute()")
  end
end

return pomo
