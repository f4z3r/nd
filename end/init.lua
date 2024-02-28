-- local config = require("end.config")
local args = require("end.args")
local entry = require("end.entry")

local opts = args.parse()
if opts.hello then
  entry.add("hello")
elseif opts.add then
  entry.add(opts.entry)
end

