-- local config = require("end.config")
local args = require("end.args")
local entry_log = require("end.entry_log")

local opts = args.parse()
if opts.hello then
  entry_log.add("hello")
elseif opts.add then
  entry_log.add(opts.entry)
elseif opts.report then
  local entries = entry_log.get_entries(opts.date)
  local sum = 0
  for _, entry in ipairs(entries) do
    sum = sum + entry:pomodoros()
  end
  print("Total pomodoros:", sum)
end

