local string = require("string")

local entry_log = require("nd.entry_log")
local report = require("nd.report")

local function handle_add(options)
  entry_log.ensure_exists()
  entry_log.add(options.entry)
end

local function handle_hello(_)
  entry_log.ensure_exists()
  entry_log.add("hello", "\n")
end

local function handle_report(options)
  print(string.format("Showing report for %s", options.date))
  report.simple_report(options.date, options.project, options.context, options.tag)
end

local function handle_edit(_)
  entry_log.ensure_exists()
  entry_log.edit_log()
end

local actions = {
  add = handle_add,
  hello = handle_hello,
  edit = handle_edit,
  report = handle_report,
}

local M = {}

---Handle the command provided by the user.
---@param options table The arguments from argparse.
function M.handle_command(options)
  if not options.command then
    handle_edit(options)
  else
    actions[options.command](options)
  end
end

return M
