local add = require("nd.commands.add")
local str_utils = require("nd.utils.strings")

local hello = {}

function hello.register_command(parser)
  local _ = parser:command("hello"):summary("Start tracking time for the day."):description(str_utils.trim_indents([[
    Starts tracking time for the day by creating a "hello" entry in the entry log
    at the current time.]]))
end

function hello.execute(options)
  -- delegate execution to add command
  options.entry = "hello"
  add.execute(options)
end

return hello
