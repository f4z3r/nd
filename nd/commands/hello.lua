local str_utils = require("nd.utils.strings")

local hello = {}

function hello.register_command(parser)
  local _ = parser:command("hello"):summary("Start tracking time for the day."):description(str_utils.trim_indents([[
    Starts tracking time for the day by creating a "hello" entry in the entry log
    at the current time.]]))
end

function hello.execute(_)
  local entry_log = require("nd.entry_log")
  entry_log.add("hello", "\n")
end

return hello
