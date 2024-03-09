local complete = {}

function complete.register_command(parser)
  local _ = parser:command("complete"):hidden(true)
end

function complete.execute(options)
  error("not implemented")
end

return complete
