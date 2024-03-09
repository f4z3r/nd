local str_utils = require("nd.utils.strings")

local entry_log = require("nd.entry_log")

local edit = {}

function edit.register_command(parser)
  local _ = parser:command("edit"):summary("Edit the entry log manually."):description(str_utils.trim_indents([[
    Launch your editor and open the entry log. This enables editing the entry log
    manually to correct errors or edit entries. The EDITOR environment variable
    defines which editor will be launched. If the variable is not defined, end will
    attempt to launch nvim.]]))
end

function edit.execute(_)
  entry_log.ensure_exists()
  entry_log.edit_log()
end

return edit
