local commands = require("nd.commands")

local opts = commands.parse()
local cmd = opts.command

if cmd then
  require("nd.commands." .. cmd).execute(opts)
else
  require("nd.commands.edit").execute(opts)
end
