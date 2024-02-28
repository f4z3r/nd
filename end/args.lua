local argparse = require("argparse")

local END_NAME = "end"
local EXAMPLE = [[Time tracking tool that incorporates pomorodo timers and
is plugin capable.]]

local _M = {}

function _M.parse()
  local parser = argparse(END_NAME, EXAMPLE)
  local _ = parser:command("hello", "Start tracking time for the day.")
  local add = parser:command("add", "Add a time tracking entry.")
  add:argument("entry", "The entry to add.")
  return parser:parse()
end

return _M
