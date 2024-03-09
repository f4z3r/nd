require("compat53")

local args = require("nd.args")

local opts = args.parse()
local cmd = opts.command

require("nd.commands." .. cmd).execute(opts)
