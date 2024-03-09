local args = require("nd.args")

local opts = args.parse()
local cmd = opts.command

if cmd then
  require("nd.commands." .. cmd).execute(opts)
else
  require("nd.commands.edit").execute(opts)
end
