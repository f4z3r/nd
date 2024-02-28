local argparse = require("argparse")
local date = require("date")

local END_NAME = "end"
local EXAMPLE = [[Time tracking tool that incorporates pomorodo timers and
is plugin capable.]]

local M = {}

function M.parse()
  local parser = argparse(END_NAME, EXAMPLE)
  local _ = parser:command("hello", "Start tracking time for the day.")

  local add = parser:command("add", "Add a time tracking entry.")
  add:argument("entry", "The entry to add.")

  local report = parser:command("report", "Report activity for a day.")
  report:argument("date", "The date of the report.", date():fmt("%F"))

  return parser:parse()
end

return M
