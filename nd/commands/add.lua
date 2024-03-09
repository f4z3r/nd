local entry_log = require("nd.entry_log")
local str_utils = require("nd.utils.strings")

local add = {}

function add.register_command(parser)
  local add_parser = parser:command("add"):summary("Add a time tracking entry."):description(str_utils.trim_indents([[
    Adds an entry in the entry log at the current time with the argument
    provided. The argument can be any string of the correct format:

    <project>: <description>

    - <project>: is optional, can start with an '!' to ommit in the reporting.
    - <descrpition>: any string. Can contain any number of tags marked with '+'
      and at most on context marked with '@'.

    Example:
       $ nd add 'nd-project: continue improving documentation +docs +nd @home']]))
  add_parser:argument("entry", "The entry to add. See format in command description.")
end

function add.execute(options)
  entry_log.add(options.entry)
end

return add
