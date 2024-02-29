local entry_log = require("nd.entry_log")

local M = {}

---Handle the command provided by the user.
---@param options table The arguments from argparse.
function M.handle_command(options)
  if options.hello then
    entry_log.ensure_exists()
    entry_log.add("hello")
  elseif options.edit then
    entry_log.ensure_exists()
    entry_log.edit_log()
  elseif options.add then
    entry_log.ensure_exists()
    entry_log.add(options.entry)
  elseif options.report then
    local entries = entry_log.get_entries(options.date)
    local sum = 0
    for _, entry in ipairs(entries) do
      sum = sum + entry:pomodoros()
    end
    print("Total pomodoros:", sum)
  else
    entry_log.ensure_exists()
    entry_log.edit_log()
  end
end

return M
