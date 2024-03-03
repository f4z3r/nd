require("compat53")

local args = require("nd.args")
local commands = require("nd.commands")

local opts = args.parse()
commands.handle_command(opts)
